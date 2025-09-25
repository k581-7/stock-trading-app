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
    # user already has a wallet from after_create :ensure_wallet!
    user.wallet.update!(balance: balance)
    user
  end

  it "POST /trades/buy reduces wallet, creates trade log, and updates portfolio" do
    stock = Stock.create!(title: "AAPL", buying_price: 150, selling_price: 155)
    user  = create_user_with_wallet!(balance: 1000)
    sign_in user

    expect {
      post buy_trade_path, params: { stock_id: stock.id, shares: 3 }
    }.to change { user.wallet.reload.balance }.from(1000).to(550)
     .and change { TradeLog.where(transaction_type: "buy").count }.by(1)
     .and change { Portfolio.where(user_id: user.id, stock_id: stock.id).exists? }.from(false).to(true)

    expect(response).to redirect_to(trade_logs_path)
    # quantity is decimal in your schema; compare as integer
    expect(Portfolio.find_by(user_id: user.id, stock_id: stock.id).quantity.to_i).to eq(3)
  end

  it "rejects when wallet has insufficient funds" do
    stock = Stock.create!(title: "TSLA", buying_price: 300, selling_price: 305)
    user  = create_user_with_wallet!(balance: 100)
    sign_in user

    post buy_trade_path, params: { stock_id: stock.id, shares: 1 }

    expect(response).to redirect_to(new_trade_path)
    expect(user.wallet.reload.balance).to eq(100)
    expect(TradeLog.where(transaction_type: "buy").count).to eq(0)
    expect(Portfolio.where(user: user, stock: stock).exists?).to be false
  end
end
