class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  def index
    @users = User.all
  end

  def approve
    user = User.find(params[:id])
    user.update(approved: true)
    redirect_to admin_users_path, notice: "#{user.username} approved as trader."
  end

  def revoke
    user = User.find(params[:id])
    user.update(approved: false)
    redirect_to admin_users_path, alert: "#{user.username}'s approval revoked."
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user&.role == "admin"
  end
end
