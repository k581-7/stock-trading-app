class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio, only: [:show, :edit, :update, :destroy, :sell]
  before_action :authorize_portfolio, only: [:show, :edit, :update, :destroy, :sell]

  def index
    # User can have multiple portfolios now
    @portfolios = current_user.portfolios.includes(:stock)
    @stocks = current_user.stocks
    @user = current_user
  end

  def show
    # Authorization handled by before_action
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
      redirect_to portfolio_path(@portfolio), alert: "Not authorized" and return
    end

    @portfolio.destroy
    redirect_to root_path, notice: "Portfolio deleted successfully."
  end

  def update_prices
    UpdateStockPricesJob.perform_later
    redirect_to portfolios_path, notice: "Stock prices are updating..."
  end

  def sell
    @stock = @portfolio.stock
    sell_quantity = params[:quantity].to_i
    sell_quantity = @portfolio.quantity if sell_quantity <= 0 # fallback, sell all

    if sell_quantity > 0 && sell_quantity <= @portfolio.quantity
      sell_value = @stock.current_price.to_f * sell_quantity

      # update portfolio quantity
      @portfolio.update(quantity: @portfolio.quantity - sell_quantity)

      # delete portfolio row if ubos na
      @portfolio.destroy if @portfolio.quantity <= 0

      # update wallet balance
      wallet = current_user.wallet || current_user.create_wallet!(balance: 0)
      wallet.increment!(:balance, sell_value)

      # create trade log
      TradeLog.create!(
        user: current_user,
        stock: @stock,
        wallet: wallet,
        transaction_type: "sell",
        quantity: sell_quantity,
        amount: sell_value
      )

      redirect_to portfolio_path(@portfolio), notice: "Sold #{sell_quantity} shares of #{@stock.symbol} for #{sell_value}."
    else
      redirect_to portfolio_path(@portfolio), alert: "Invalid sell quantity."
    end
  end

  private

  def set_portfolio
    @portfolio = current_user.portfolios.find_by(id: params[:id])
  end

  def authorize_portfolio
    unless @portfolio
      redirect_to root_path, alert: "Not authorized"
    end
  end

  def portfolio_params
    params.require(:portfolio).permit(:stock_id, :quantity)
  end
end
