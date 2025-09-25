require "rails_helper"

RSpec.describe "Trades (buy)", type: :request do
  def create_user_with_wallet!(balance: 0)
    user = User.create!(
      email: "buyer#{SecureRandom.hex(2)}@ex.com",
      username: "buyer_#{SecureRandom.hex(2)}",
      password: "Password1!",
      password_confirmation: "Password1!",
      confirmed_at: Time.current
    )
    user.wallet.update!(balance: balance)
    user
  end

  it "POST /trades/buy reduces wallet, creates trade log, and updates portfolio" do
    stock = Stock.create!(name: "Apple", symbol: "AAPL", current_price: 120.0)
    user  = create_user_with_wallet!(balance: 1000)
    sign_in user

    post buy_trade_path, params: { stock_id: stock.id, shares: 3 }

    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(trade_logs_path)

    user.reload
    expected_cost = stock.current_price * 3
    expected_balance = 1000 - expected_cost

    expect(user.wallet.balance.to_f).to eq(expected_balance)
    
    log = TradeLog.order(:created_at).last
    expect(log.transaction_type).to eq("buy")
    expect(log.amount.to_f).to eq(expected_cost)

    pf = Portfolio.find_by(user_id: user.id, stock_id: stock.id)
    expect(pf).to be_present
    expect(pf.quantity.to_f).to eq(3.0)
  end

  it "rejects when wallet has insufficient funds" do
    stock = Stock.create!(name: "Tesla", symbol: "TSLA", current_price: 150.0)
    user  = create_user_with_wallet!(balance: 100)
    sign_in user

    post buy_trade_path, params: { stock_id: stock.id, shares: 1 }

    expect(response).to redirect_to(new_trade_path)
    expect(user.wallet.reload.balance.to_f).to eq(100.0)
    expect(TradeLog.where(transaction_type: "buy").count).to eq(0)
    expect(Portfolio.where(user_id: user.id, stock_id: stock.id).exists?).to be false
  end
end