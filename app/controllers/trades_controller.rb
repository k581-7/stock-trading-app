class TradesController < ApplicationController
  before_action :authenticate_user!
  skip_forgery_protection if Rails.env.test?

  def new
    @stocks = Stock.order(:symbol)

    if params[:stock_id].present?
      @selected_stock = Stock.find_by(id: params[:stock_id])
      @portfolio_entry = current_user.portfolios.find_by(stock: @selected_stock)
    end

    @top_gainers = Stock.where("percent_change > 0").order(percent_change: :desc).limit(3)
    @top_losers = Stock.where("percent_change < 0").order(percent_change: :asc).limit(3)
  end


  def buy
    stock  = Stock.find(params[:stock_id])
    shares = BigDecimal(params[:shares].to_s)
    price  = BigDecimal(stock.current_price.to_s)
    cost   = shares * price

    return head :unprocessable_content if shares <= 0

    wallet = current_user.wallet || current_user.create_wallet!(balance: 0)
    return head :unprocessable_content if wallet.balance < cost

    ActiveRecord::Base.transaction do
      wallet.update!(balance: wallet.balance - cost)

      portfolio = Portfolio.find_or_create_by!(user: current_user, stock: stock) do |p|
        p.quantity = 0
      end
      portfolio.update!(quantity: portfolio.quantity + shares)

      TradeLog.create!(
        user: current_user,
        stock: stock,
        wallet: wallet,
        transaction_type: "buy",
        quantity: shares,
        amount: cost
      )
    end

    head :ok
  end

  def sell
    stock  = Stock.find(params[:stock_id])
    shares = BigDecimal(params[:shares].to_s)
    price  = BigDecimal(stock.current_price.to_s)
    revenue = shares * price

    remaining_quantity = 0

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

      remaining_quantity = portfolio.quantity - shares

      if remaining_quantity <= 0
        portfolio.destroy!
      else
        portfolio.update!(quantity: remaining_quantity)
      end

      TradeLog.create!(
        user: current_user,
        stock: stock,
        wallet: wallet,
        transaction_type: "sell",
        quantity: shares,
        amount: revenue
      )
    end

    if remaining_quantity <= 0
      redirect_to portfolios_path, notice: "All shares of #{stock.symbol} sold successfully."
    else
      redirect_to portfolios_path, notice: "Sell executed. Remaining shares: #{remaining_quantity.to_i}."
    end
  end
end
