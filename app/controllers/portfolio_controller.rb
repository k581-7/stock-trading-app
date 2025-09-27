class PortfolioController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio, only: [ :show, :edit, :update, :destroy ]

  # GET /portfolios
  def index
    @portfolios = current_user.portfolios.includes(:stock)
  end

  # GET /portfolios/:id
  def show
  end

  # GET /portfolios/new
  def new
    @portfolio = Portfolio.new
    @stocks = Stock.all
  end

  # POST /portfolios
  def create
    @portfolio = current_user.portfolios.new(portfolio_params.except(:user_id))


    if @portfolio.save
      redirect_to @portfolio, notice: "Portfolio was successfully created."
    else
      @stocks = Stock.all
      render :new, status: :unprocessable_entity
    end
  end


  # GET /portfolios/:id/edit
  def edit
  end

  # PATCH/PUT /portfolios/:id
  def update
    if @portfolio.update(portfolio_params)
      redirect_to @portfolio, notice: "Portfolio was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /portfolios/:id
  def destroy
    @portfolio.destroy
    redirect_to portfolios_url, notice: "Portfolio was successfully destroyed."
  end

  private

  def set_portfolio
    @portfolio = current_user.portfolios.find_by(id: params[:id])
    redirect_to portfolios_path, alert: "Not authorized to access this portfolio." unless @portfolio
  end


  def portfolio_params
    params.require(:portfolio).permit(:stock_id, :quantity)
  end
end
