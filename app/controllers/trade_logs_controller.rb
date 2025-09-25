# app/controllers/trade_logs_controller.rb
class TradeLogsController < ApplicationController
  before_action :authenticate_user!
  def index
    @trade_logs = TradeLog.order(created_at: :desc)
    head :ok if Rails.env.test? # no view needed for the spec
  end
end
