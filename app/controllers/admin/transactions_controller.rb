class Admin::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  def index
    @transactions = TradeLog.includes(:user, :stock).order(created_at: :desc)

    # counts
    @total_tx   = @transactions.size
    @buy_count  = @transactions.count { |t| t.transaction_type == "buy" }
    @sell_count = @transactions.count { |t| t.transaction_type == "sell" }

    # total
    @total_volume = @transactions.sum { |t| (t.quantity || 0) * (t.amount || 0) }
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user&.admin?
  end
end
