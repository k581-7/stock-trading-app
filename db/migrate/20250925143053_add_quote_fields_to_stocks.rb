class AddQuoteFieldsToStocks < ActiveRecord::Migration[8.0]
  def change
    add_column :stocks, :price_change, :decimal, precision: 10, scale: 2
    add_column :stocks, :percent_change, :decimal, precision: 5, scale: 2
    add_column :stocks, :volume, :bigint
    add_column :stocks, :market_open, :boolean, default: false
  end
end
