class StocksController < ApplicationController
  def index
      @stocks = Stock.all
  end

  def show
    @stock = Stock.find(params[:id])
  end

  def test_quote
    finnhub = FinnhubService.new
    data = finnhub.quote("AAPL")
    render json: data
  end

  def update_prices
  UpdateStockPricesJob.perform_now
  redirect_back fallback_location: portfolios_path, notice: "Stock prices updated successfully."
  end
end
