require "rails_helper"

RSpec.describe "Trades (sell)", type: :request do
  def create_user_with_wallet!(balance: 0, approved: true)
    user = User.create!(
      email: "seller#{SecureRandom.hex(2)}@ex.com",
      username: "seller_#{SecureRandom.hex(2)}",
      password: "Password1!",
      confirmed_at: Time.current,
      approved: approved
    )
    user.wallet.update!(balance: balance)
    user
  end

  it "POST /trades/sell increases wallet, creates trade log, and decreases portfolio" do
    stock = Stock.create!(name: "Apple", symbol: "AAPL", current_price: 155.0)
    user  = create_user_with_wallet!(balance: 100, approved: true)
    sign_in user
    Portfolio.create!(user: user, stock: stock, quantity: 5)

    post sell_trade_path, params: { stock_id: stock.id, shares: 2 }

    expect(response).to redirect_to(trade_logs_path)
    expect(user.wallet.reload.balance.to_d).to eq(410.to_d) # 100 + (2 * 155)

    log = TradeLog.order(:created_at).last
    expect(log.transaction_type).to eq("sell")
    expect(log.amount.to_d).to eq(310.to_d)
    expect(log.quantity.to_d).to eq(2.to_d)

    pf = Portfolio.find_by(user: user, stock: stock)
    expect(pf.quantity.to_d).to eq(3.to_d)
  end

  it "rejects when selling more than owned" do
    stock = Stock.create!(name: "Tesla", symbol: "TSLA", current_price: 150.0)
    user  = create_user_with_wallet!(balance: 50, approved: true)
    sign_in user
    Portfolio.create!(user: user, stock: stock, quantity: 1)

    post sell_trade_path, params: { stock_id: stock.id, shares: 2 }

    expect(response).to redirect_to(new_trade_path)
    expect(user.wallet.reload.balance.to_d).to eq(50.to_d)
    expect(TradeLog.where(transaction_type: "sell").count).to eq(0)
    expect(Portfolio.find_by(user: user, stock: stock).quantity.to_d).to eq(1.to_d)
  end

  it "blocks unapproved trader from selling stocks" do
    stock = Stock.create!(name: "Netflix", symbol: "NFLX", current_price: 120.0)
    user  = create_user_with_wallet!(balance: 500, approved: false)
    sign_in user
    Portfolio.create!(user: user, stock: stock, quantity: 3)

    post sell_trade_path, params: { stock_id: stock.id, shares: 1 }

    expect(response).to redirect_to(new_trade_path)
    follow_redirect!
    expect(response.body).to include("Your account must be approved to sell stocks.")
    expect(user.wallet.reload.balance.to_d).to eq(500.to_d)
    expect(TradeLog.where(transaction_type: "sell").count).to eq(0)
    expect(Portfolio.find_by(user: user, stock: stock).quantity.to_d).to eq(3.to_d)
  end
end
