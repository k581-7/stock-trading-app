class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  def approve
    user = User.find(params[:id])
    user.update(role: "trader")
    redirect_to admin_users_path, notice: "#{user.username} approved as trader."
  end

  def revoke
    user = User.find(params[:id])
    user.update(role: "user")
    redirect_to admin_users_path, notice: "#{user.username}'s approval revoked."
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user&.admin?
  end
end
