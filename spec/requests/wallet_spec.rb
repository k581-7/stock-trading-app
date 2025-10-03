require 'rails_helper'

RSpec.describe "Wallets", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:user) do
    User.create!(
      username: "testuser",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123",
      first_name: "Test",
      last_name: "User",
      broker_status: "broker_approved"
    )
  end

  let!(:wallet) do
  Wallet.where(user: user).destroy_all
  Wallet.create!(user: user, balance: 1000)
end

  before do
    user.confirm
    sign_in user  
  end

  describe "GET /wallet" do
    it "shows wallet and logs" do
  TradeLog.create!(user: user, wallet: wallet, transaction_type: "buy",     amount: 100, quantity: 1)
  TradeLog.create!(user: user, wallet: wallet, transaction_type: "deposit", amount: 200, quantity: 0)
  TradeLog.create!(user: user, wallet: wallet, transaction_type: "sell",    amount: 50,  quantity: 1)  # add this

  get wallet_path

  expect(response).to have_http_status(:ok)
  expect(response.body).to include("Wallet")
  expect(response.body).to include("BUY")
  expect(response.body).to include("SELL")
end


    it "shows empty logs if wallet is missing" do
      wallet.destroy
      get wallet_path
      expect(response.body).to include("Wallet")
    end
  end

  describe "POST /wallet/top_up" do
    it "adds funds and creates deposit log" do
      expect {
        post top_up_wallet_path, params: { amount: 500 }
      }.to change { wallet.reload.balance }.by(500)
       .and change { TradeLog.count }.by(1)

      expect(response).to redirect_to(wallet_path)
      follow_redirect!
      expect(response.body).to include("Added")
    end

    it "rejects invalid amount" do
      expect {
        post top_up_wallet_path, params: { amount: 0 }
      }.not_to change { wallet.reload.balance }

      expect(response).to redirect_to(wallet_path)
      follow_redirect!
      expect(response.body).to include("Enter a valid amount")
    end
  end

describe "POST /wallet/withdraw" do
  it "withdraws funds and creates log" do
    initial_balance = wallet.balance

    post withdraw_wallet_path, params: { amount: 300 }

    expect(response).to redirect_to(wallet_path)
    follow_redirect!

    expect(wallet.reload.balance).to eq(initial_balance - 300)
    expect(TradeLog.last).to have_attributes(
      user_id: user.id,
      wallet_id: wallet.id,
      transaction_type: "withdraw",
      amount: 300
    )
    expect(response.body).to include("Successfully withdrew") 
  end

    it "rejects invalid or excessive amount" do
      expect {
        post withdraw_wallet_path, params: { amount: 2000 }
      }.not_to change { wallet.reload.balance }

      expect(response).to redirect_to(wallet_path)
      follow_redirect!
      expect(response.body).to include("Invalid amount or insufficient balance")
    end
  end
end
