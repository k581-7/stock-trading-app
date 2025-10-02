class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_user, only: [ :approve, :revoke, :show, :approve_broker, :reject_broker, :show, :edit, :update, :delete ]

  def index
    @allusers = User.all
    @users = User.where(approved: false, role: :trader)
    @pending_brokers = User.where(broker_status: :broker_pending, role: :trader)
    @approved_brokers = User.where(broker_status: :broker_approved)
    @last_stock_update = Stock.where.not(last_updated_at: nil).maximum(:last_updated_at)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.confirm
      redirect_to admin_user_path(@user), notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user
  end

  def edit
    @user
  end

  def update
    if @user.update(user_edit_params)
      redirect_to admin_user_path(@user), notice: "User updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def delete
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  def all_users
    @allusers = User.all
  end
  def pending_approvals
    @users = User.where(approved: false, role: :trader)
    @pending_brokers = User.where(broker_status: :broker_pending, role: :trader)
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
      @user.update!(role: :broker, broker_status: :broker_approved, broker_approval_date: Time.current)
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

  def user_params
    params.require(:user).permit(:email, :username, :password, :approved)
  end

  def user_edit_params
    params.require(:user).permit(:email, :username)
  end
end
