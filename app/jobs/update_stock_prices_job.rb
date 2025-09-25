require "finnhub_ruby"

class UpdateStockPricesJob < ApplicationJob
  queue_as :default

  def perform
    client = FinnhubRuby::DefaultApi.new

    Stock.find_each do |stock|
      begin
        quote = client.quote(stock.symbol)
        sleep(1.1) # Respect Finnhub's rate limit

        stock.update!(
          current_price:      quote["c"],
          price_change:       quote["d"],
          percent_change:     quote["dp"],
          last_updated_at:    Time.current
        )

        Rails.logger.info "Updated #{stock.symbol} → #{quote['c']} (#{quote['d']} / #{quote['dp']}%)"
      rescue FinnhubRuby::ApiError => e
        Rails.logger.error "Finnhub API error for #{stock.symbol}: #{e.message}"
        next
      end
    end
  end
end