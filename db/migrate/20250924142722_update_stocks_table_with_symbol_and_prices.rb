class UpdateStocksTableWithSymbolAndPrices < ActiveRecord::Migration[8.0]
  def change
    remove_column :stocks, :title, :string
    remove_column :stocks, :buying_price, :decimal
    remove_column :stocks, :selling_price, :decimal

    add_column :stocks, :symbol, :string, null: false
    add_column :stocks, :company_name, :string
    add_column :stocks, :current_price, :decimal, precision: 10, scale: 2
    add_column :stocks, :last_refreshed, :datetime
  end
end
sudo service postgresql status
