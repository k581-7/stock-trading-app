# app/services/finnhub_service.rb
require "net/http"
require "json"

class FinnhubService
  BASE_URL = "https://finnhub.io/api/v1"

  def initialize
    @api_key = ENV["FINNHUB_API_KEY"] # secure, nasa credentials or .env
  end

  # Example: Get current stock price by symbol
  def quote(symbol)
    url = URI("#{BASE_URL}/quote?symbol=#{symbol}&token=#{@api_key}")
    response = Net::HTTP.get(url)
    JSON.parse(response) # returns hash
  end

  # Example: Get company profile by symbol
  def company_profile(symbol)
    url = URI("#{BASE_URL}/stock/profile2?symbol=#{symbol}&token=#{@api_key}")
    response = Net::HTTP.get(url)
    JSON.parse(response)
  end

  # Example: Search companies
  def search_company(query)
    url = URI("#{BASE_URL}/search?q=#{query}&token=#{@api_key}")
    response = Net::HTTP.get(url)
    JSON.parse(response)
  end
end
