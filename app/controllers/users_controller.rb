class UsersController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    # trader/broker user-facing logic
  end

  def apply_for_broker
    if current_user.trader? && current_user.no_application?
      current_user.update!(broker_status: :broker_pending)
      redirect_to dashboard_path, notice: "Broker application submitted."
    else
      redirect_to dashboard_path, alert: "Cannot apply for broker."
    end
  end
end
