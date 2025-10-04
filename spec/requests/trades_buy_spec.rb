require "rails_helper"

RSpec.describe "Trades (buy)", type: :request do
  include Devise::Test::IntegrationHelpers

  def create_user_with_wallet!(balance: 0)
    user = User.create!(
      email: "buyer#{SecureRandom.hex(2)}@ex.com",
      username: "buyer_#{SecureRandom.hex(2)}",
      password: "Password1!",
      password_confirmation: "Password1!",
      first_name: "Buyer",
      last_name: "Test",
      broker_status: "broker_approved",
      confirmed_at: Time.current
    )

    wallet = Wallet.find_or_initialize_by(user: user)
    wallet.balance = balance
    wallet.save!
    user
  end

  it "POST /trades/buy decreases wallet, creates trade log, and increases portfolio" do
    stock = Stock.create!(name: "Apple", symbol: "AAPL", current_price: 155.0)
    user  = create_user_with_wallet!(balance: 1000)
    sign_in user

    post buy_trade_path, params: { stock_id: stock.id, shares: 2 }

    expect(response).to redirect_to(portfolios_path), "Actual redirect: #{response.redirect_url}"
    expect(user.wallet.reload.balance.to_d).to eq(690.to_d)

    log = TradeLog.where(wallet: user.wallet).order(:created_at).last
    expect(log.transaction_type).to eq("buy")
    expect(log.amount.to_d).to eq(310.to_d)
    expect(log.quantity.to_d).to eq(2.to_d)

    pf = Portfolio.find_by(user: user, stock: stock)
    expect(pf.quantity.to_d).to eq(2.to_d)
  end

  it "rejects when buying more than wallet balance allows" do
    stock = Stock.create!(name: "Tesla", symbol: "TSLA", current_price: 150.0)
    user  = create_user_with_wallet!(balance: 100)
    sign_in user

    post buy_trade_path, params: { stock_id: stock.id, shares: 2 }

    expect(response).to redirect_to(new_trade_path), "Actual redirect: #{response.redirect_url}"
    expect(user.wallet.reload.balance.to_d).to eq(100.to_d)
    expect(TradeLog.where(transaction_type: "buy", wallet: user.wallet).count).to eq(0)
    expect(Portfolio.find_by(user: user, stock: stock)).to be_nil
  end

  it "rejects when buying with invalid share count" do
    stock = Stock.create!(name: "Netflix", symbol: "NFLX", current_price: 120.0)
    user  = create_user_with_wallet!(balance: 500)
    sign_in user

    post buy_trade_path, params: { stock_id: stock.id, shares: 0 }

    expect(response).to redirect_to(new_trade_path), "Actual redirect: #{response.redirect_url}"
    follow_redirect!
    expect(response.body).to include("Invalid number of shares.")
    expect(user.wallet.reload.balance.to_d).to eq(500.to_d)
    expect(TradeLog.where(transaction_type: "buy", wallet: user.wallet).count).to eq(0)
    expect(Portfolio.find_by(user: user, stock: stock)).to be_nil
  end
end
