class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_user, only: [ :approve, :revoke, :show, :approve_broker, :reject_broker ]

  def index
    @users = User.where(approved: false)
    @pending_brokers = User.where(broker_status: :broker_pending, role: :trader)
  end

  def show
  end

  def approve
    if @user.trader? && !@user.approved?
      @user.update!(approved: true, approval_date: Time.current)
      @user.confirm unless @user.confirmed?
      TraderMailer.approval_email(@user).deliver_now
      redirect_to admin_users_path, notice: "#{@user.username} approved as trader and email sent!"
    else
      redirect_to admin_users_path, alert: "#{@user.username} is already approved."
    end
  end

  def revoke
    if @user.trader? && @user.approved?
      @user.update!(approved: false, approval_date: nil)
      redirect_to admin_users_path, alert: "#{@user.username}'s approval revoked."
    else
      redirect_to admin_users_path, alert: "#{@user.username} is not an approved trader."
    end
  end

  def approve_broker
    if @user.trader? && @user.broker_pending?
      @user.update!(broker_status: :broker_approved, broker_approval_date: Time.current)
      redirect_to admin_users_path, notice: "#{@user.username} approved as broker and email sent!"
    else
      redirect_to admin_users_path, alert: "Cannot approve broker for this user."
    end
  end

  def reject_broker
    if @user.trader? && @user.pending?
      @user.update!(broker_status: :broker_rejected)
      redirect_to admin_users_path, alert: "#{@user.username}'s broker application rejected."
    else
      redirect_to admin_users_path, alert: "Cannot reject broker for this user."
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
