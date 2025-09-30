class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Wallet and Portfolio
    @wallet = current_user.wallet
    @portfolio = current_user.portfolios.first

    # Wallet Balance as Portfolio Value Substitute
    @wallet_balance = @wallet.balance

    # Day P/L (placeholder or calculated from trade_logs)
    @day_pl = current_user.day_profit_loss rescue 0

    # Trade Stats
    @total_trades = current_user.trade_logs.count
    @buy_trades   = current_user.trade_logs.where(transaction_type: 'buy').count
    @sell_trades  = current_user.trade_logs.where(transaction_type: 'sell').count

    # Activity Logs
    @wallet_logs  = current_user.trade_logs.where(transaction_type: %w[deposit withdraw])
    @trade_history = current_user.trade_logs.where(transaction_type: %w[buy sell])
    @trade_logs   = current_user.trade_logs.order(created_at: :desc)

    # Market Overview
    @stocks = Stock.order(:symbol).limit(12)

    @top_gainers = Stock.where("percent_change > 0").order(percent_change: :desc).limit(3)
    @top_losers  = Stock.where("percent_change < 0").order(percent_change: :asc).limit(3)
  end
end
