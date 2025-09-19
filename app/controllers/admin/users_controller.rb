class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!

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
end