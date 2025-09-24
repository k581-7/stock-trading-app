class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_user, only: [:approve, :revoke, :show]

  def index
    @users = User.all
  end

  def show
  end

  def approve
    if @user.trader?
      redirect_to admin_users_path, alert: "#{@user.username} is already a trader."
    else
      @user.update!(role: :trader, approval_date: Time.current)

      # Send approval email
      TraderMailer.approval_email(@user).deliver_now

      redirect_to admin_users_path, notice: "#{@user.username} approved as trader and email sent!"
    end
  end

  def revoke
    if @user.trader?
      @user.update!(role: :pending_trader, approval_date: nil)
      redirect_to admin_users_path, alert: "#{@user.username}'s approval revoked."
    else
      redirect_to admin_users_path, alert: "#{@user.username} is not a trader."
    end
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user&.admin?
  end

  def set_user
    @user = User.find(params[:id])
  end
end
