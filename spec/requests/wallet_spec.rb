# spec/requests/trades_buy_spec.rb
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
    stock = Stock.create!(title: "AAPL", buying_price: 150, selling_price: 155)
    user  = create_user_with_wallet!(balance: 1000)
    sign_in user

    # 1) hit the endpoint and assert it didn’t 404/422
    post buy_trade_path, params: { stock_id: stock.id, shares: 3 }
    expect(response).to have_http_status(:found) # 302 redirect
    expect(response).to redirect_to(trade_logs_path)

    # 2) assert DB side-effects explicitly
    user.reload
    expect(user.wallet.balance.to_d).to eq(550)
    log = TradeLog.order(:created_at).last
    expect(log.transaction_type).to eq("buy")
    expect(log.amount.to_d).to eq(450)

    pf = Portfolio.find_by(user_id: user.id, stock_id: stock.id)
    expect(pf).to be_present
    expect(pf.quantity.to_d).to eq(3)
  end

  it "rejects when wallet has insufficient funds" do
    stock = Stock.create!(title: "TSLA", buying_price: 300, selling_price: 305)
    user  = create_user_with_wallet!(balance: 100)
    sign_in user

    post buy_trade_path, params: { stock_id: stock.id, shares: 1 }
    expect(response).to redirect_to(new_trade_path)
    expect(user.wallet.reload.balance.to_d).to eq(100)
    expect(TradeLog.where(transaction_type: "buy").count).to eq(0)
    expect(Portfolio.where(user: user, stock: stock).exists?).to be false
  end
end
