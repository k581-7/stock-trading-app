class FinnhubService
  include HTTParty
  base_uri "https://finnhub.io/api/v1"

  def initialize
    @token = ENV["FINNHUB_API_KEY"]
  end

  def quote(symbol)
    self.class.get("/quote", query: { symbol: symbol, token: @token })
  end

  def profile(symbol)
    self.class.get("/stock/profile2", query: { symbol: symbol, token: @token })
  end

  def candles(symbol, resolution = "D", from = 7.days.ago.to_i, to = Time.now.to_i)
    self.class.get("/stock/candle", query: {
      symbol: symbol,
      resolution: resolution,
      from: from,
      to: to,
      token: @token
    })
  end
end
