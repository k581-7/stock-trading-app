require "finnhub_ruby"

class UpdateStockPricesJob < ApplicationJob
  queue_as :default

  def perform
    puts "Starting stock price update job..."
    FinnhubRuby.configure do |config|
      config.api_key["api_key"] = ENV["FINNHUB_API_KEY"]
    end

    client = FinnhubRuby::DefaultApi.new
      Stock.find_each do |stock|
      begin
        quote = client.quote(stock.symbol)

        stock.update!(
          current_price:      quote["c"],
          price_change:       quote["d"],
          percent_change:     quote["dp"],
          last_updated_at:    Time.current
        )
        puts "It's working"
        sleep(1.1) # Respect Finnhub's rate limit

        Rails.logger.info "Updated #{stock.symbol} → #{quote['c']} (#{quote['d']} / #{quote['dp']}%)"
      rescue StandardError => e
        Rails.logger.error "Finnhub API error for #{stock.symbol}: #{e.message}"
        next
      end
    end
    puts "Finished stock price update job."
  end
end
