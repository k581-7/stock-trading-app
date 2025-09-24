class UpdateStockPricesJob < ApplicationJob
  queue_as :default

  def perform
    Stock.find_each do |stock|
      data = FinnhubService.new.quote(stock.symbol)
      if data.present? && data["c"].present?
        stock.update!(
          current_price: data["c"],
          last_updated_at: Time.current
        )
        Rails.logger.info "Updated #{stock.symbol} → #{data['c']}"
      else
        Rails.logger.warn "No data for #{stock.symbol}"
      end
    end
  end
end
