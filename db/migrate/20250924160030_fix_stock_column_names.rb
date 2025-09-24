class FixStockColumnNames < ActiveRecord::Migration[8.0]
  def change
    rename_column :stocks, :company_name, :name
    rename_column :stocks, :last_refreshed, :last_updated_at
    change_column :stocks, :current_price, :decimal, precision: 15, scale: 2
  end
end