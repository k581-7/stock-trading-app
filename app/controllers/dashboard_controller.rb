class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Portfolio and Wallet
    @portfolio = current_user.portfolios.first
    @wallet = current_user.wallet

    # Portfolio Value and Day P/L
    @portfolio_value = current_user.portfolios
    @day_pl = current_user.day_profit_loss

    # Trade Stats
    @total_trades = current_user.trade_logs.count
    @buy_trades = current_user.trade_logs.where(transaction_type: 'buy').count
    @sell_trades = current_user.trade_logs.where(transaction_type: 'sell').count

    # Activity Logs
    @wallet_logs = current_user.trade_logs.where(transaction_type: %w[deposit withdraw])
    @trade_history = current_user.trade_logs.where(transaction_type: %w[buy sell])
    @trade_logs = current_user.trade_logs.order(created_at: :desc)

    # Market Overview
    @stocks = Stock.order(:symbol).limit(8)
  end
end
