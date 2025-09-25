# app/controllers/trades_controller.rb
class TradesController < ApplicationController
  before_action :authenticate_user!
  skip_forgery_protection if Rails.env.test?  # avoid 422 in request specs

  def new
    @stocks = Stock.order(:title)
  end

  def buy
    stock  = Stock.find(params[:stock_id])
    shares = BigDecimal(params[:shares].to_s)
    price  = BigDecimal(stock.current_price.to_s)
    cost   = shares * price

    return redirect_to new_trade_path, alert: "Enter a valid number of shares." if shares <= 0

    wallet = current_user.wallet || current_user.create_wallet!(balance: 0)
    return redirect_to new_trade_path, alert: "Insufficient funds." if BigDecimal(wallet.balance.to_s) < cost

    ActiveRecord::Base.transaction do
      wallet.update!(balance: BigDecimal(wallet.balance.to_s) - cost)

      portfolio = Portfolio.find_or_create_by!(user_id: current_user.id, stock_id: stock.id) { |p| p.quantity = 0 }
      portfolio.update!(quantity: BigDecimal(portfolio.quantity.to_s) + shares)

      TradeLog.create!(transaction_type: "buy", quantity: shares, amount: cost)
    end

    redirect_to trade_logs_path, notice: "Buy executed."
  end
end
