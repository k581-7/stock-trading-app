require 'rails_helper'

RSpec.describe "Wallets", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:user) do
    User.create!(
      username: "testuser",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let!(:wallet) do
    Wallet.create!(
      user: user,
      balance: 1000
    )
  end

  before do
    sign_in user
  end

  describe "GET /wallet" do
    it "shows wallet and logs" do
      TradeLog.create!(user: user, wallet: wallet, transaction_type: "buy", amount: 100, quantity: 1)
      TradeLog.create!(user: user, wallet: wallet, transaction_type: "deposit", amount: 200, quantity: 0)

      get wallet_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Wallet")
      expect(response.body).to include("buy")
      expect(response.body).to include("deposit")
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
        post top_up_wallets_path, params: { amount: 500 }
      }.to change { wallet.reload.balance }.by(500)
       .and change { TradeLog.count }.by(1)

      expect(response).to redirect_to(wallet_path)
      follow_redirect!
      expect(response.body).to include("Added")
    end

    it "rejects invalid amount" do
      expect {
        post top_up_wallets_path, params: { amount: 0 }
      }.not_to change { wallet.reload.balance }

      expect(response).to redirect_to(wallet_path)
      follow_redirect!
      expect(response.body).to include("Enter a valid amount")
    end
  end

  describe "POST /wallet/withdraw" do
    it "withdraws funds and creates log" do
      expect {
        post withdraw_wallets_path, params: { amount: 300 }
      }.to change { wallet.reload.balance }.by(-300)
       .and change { TradeLog.count }.by(1)

      expect(response).to redirect_to(wallet_path)
      follow_redirect!
      expect(response.body).to include("Withdrew")
    end

    it "rejects invalid or excessive amount" do
      expect {
        post withdraw_wallets_path, params: { amount: 2000 }
      }.not_to change { wallet.reload.balance }

      expect(response).to redirect_to(wallet_path)
      follow_redirect!
      expect(response.body).to include("Invalid amount or insufficient balance")
    end
  end
end