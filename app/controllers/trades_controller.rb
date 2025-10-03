class TradesController < ApplicationController
  before_action :authenticate_user!
  skip_forgery_protection if Rails.env.test?
  def new
    @stocks = Stock.order(:symbol)
    # Add Top Gainers and Losers for UI display
    @top_gainers = Stock.where("percent_change > 0").order(percent_change: :desc).limit(3)
    @top_losers  = Stock.where("percent_change < 0").order(percent_change: :asc).limit(3)
  end
  def buy
    stock  = Stock.find(params[:stock_id])
    shares = params[:shares].to_i
    price  = stock.current_price.to_d
    cost   = shares * price

    if shares <= 0
      return redirect_to new_trade_path, alert: "Invalid number of shares."
    end

    wallet = current_user.wallet || current_user.create_wallet!(balance: 0)
    if wallet.balance < cost
      return redirect_to new_trade_path, alert: "Insufficient wallet balance."
    end

    ActiveRecord::Base.transaction do
      wallet.update!(balance: wallet.balance - cost)

      portfolio = current_user.portfolios.find_or_initialize_by(stock: stock)
      portfolio.quantity = (portfolio.quantity || 0) + shares
      portfolio.save!

      TradeLog.create!(
        user: current_user,
        stock: stock,
        wallet: wallet,
        transaction_type: "buy",
        quantity: shares,
        amount: cost
      )
    end

    redirect_to portfolios_path, notice: "Successfully bought #{shares} share(s) of #{stock.symbol}"
  end
  def sell
    stock  = Stock.find(params[:stock_id])
    shares = BigDecimal(params[:shares].to_s)
    price  = BigDecimal(stock.current_price.to_s)
    revenue = shares * price
    return head :unprocessable_content if shares <= 0
    unless current_user.approved?
      return redirect_to new_trade_path, alert: "Your account must be approved to sell stocks."
    end
    portfolio = Portfolio.find_by(user: current_user, stock: stock)
    return redirect_to new_trade_path, alert: "You don't own this stock." unless portfolio
    return redirect_to new_trade_path, alert: "Insufficient shares to sell." if portfolio.quantity < shares
    wallet = current_user.wallet || current_user.create_wallet!(balance: 0)
    ActiveRecord::Base.transaction do
      wallet.update!(balance: wallet.balance + revenue)
      portfolio.update!(quantity: portfolio.quantity - shares)
      TradeLog.create!(
        user: current_user,
        stock: stock,
        wallet: wallet,
        transaction_type: "sell",
        quantity: shares,
        amount: revenue
      )
    end
    redirect_to trade_logs_path, notice: "Sell executed."
  end
end
