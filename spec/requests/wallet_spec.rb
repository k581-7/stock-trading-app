require "rails_helper"

RSpec.describe "Trades (buy)", type: :request do
  def create_user_with_wallet!(balance: 0)
    user = User.create!(
      email: "buyer#{SecureRandom.hex(2)}@ex.com",
      username: "buyer_#{SecureRandom.hex(2)}",
      password: "Password1!",
      confirmed_at: Time.current,
      approved: true
    )
    user.wallet.update!(balance: balance)
    user
  end

  it "reduces wallet, creates trade log, and updates portfolio" do
    stock = Stock.create!(symbol: "AAPL", name: "Apple Inc.", current_price: 150)
    user  = create_user_with_wallet!(balance: 1000)
    sign_in user

    post buy_trade_path, params: { stock_id: stock.id, shares: 3 }

    expect(response).to have_http_status(:ok)
    expect(user.wallet.reload.balance.to_d).to eq(550.to_d)
    expect(TradeLog.where(user: user, transaction_type: "buy").count).to eq(1)
    expect(Portfolio.where(user: user, stock: stock).exists?).to be true
    expect(Portfolio.find_by(user: user, stock: stock).quantity.to_i).to eq(3)
  end

  it "rejects when wallet has insufficient funds" do
    stock = Stock.create!(symbol: "TSLA", name: "Tesla Inc.", current_price: 300)
    user  = create_user_with_wallet!(balance: 100)
    sign_in user

    post buy_trade_path, params: { stock_id: stock.id, shares: 1 }

    expect(response).to have_http_status(:unprocessable_content)
    expect(user.wallet.reload.balance.to_d).to eq(100.to_d)
    expect(TradeLog.where(user: user, transaction_type: "buy").count).to eq(0)
    expect(Portfolio.where(user: user, stock: stock).exists?).to be false
  end
end
