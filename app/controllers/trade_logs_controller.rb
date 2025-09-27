class TradeLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @trade_logs = current_user.trade_logs.order(created_at: :desc)
    @wallet_logs = @trade_logs.where(transaction_type: %w[deposit withdraw])
    @trade_history = @trade_logs.where(transaction_type: %w[buy sell])
  end
end