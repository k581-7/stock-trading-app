class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio, only: [:show, :edit, :update, :destroy]
  before_action :authorize_portfolio, only: [:show, :edit, :update, :destroy]
  def index
    @portfolios = current_user.portfolios.includes(:stock)
    @user = current_user
  end
  def show
    if @portfolio.user != current_user
      redirect_to portfolios_path, alert: "Not authorized"
    end
  end
  def new
    @portfolio = current_user.portfolios.new
    @stocks = Stock.all
  end
  def create
    @portfolio = current_user.portfolios.new(portfolio_params)
    if @portfolio.save
      redirect_to @portfolio, notice: "Portfolio created successfully."
    else
      @stocks = Stock.all
      render :new, status: :unprocessable_entity
    end
  end
  def edit
    # @portfolio is already loaded and authorized
  end
  def update
    if @portfolio.update(portfolio_params)
      redirect_to @portfolio, notice: "Portfolio updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    if @portfolio.user_id != current_user.id
      redirect_to portfolios_path, alert: "Not authorized" and return
    end
    @portfolio.destroy
    redirect_to portfolios_path, notice: "Portfolio deleted successfully."
  end
  private
  def set_portfolio
    @portfolio = Portfolio.includes(:stocks).find(params[:id])
  end
  def authorize_portfolio
    unless @portfolio.user_id == current_user.id
      redirect_to portfolios_path, alert: "Not authorized" and return
    end
  end
  def portfolio_params
    params.require(:portfolio).permit(:stock_id, :quantity)
  end
end