class AddStockIdToTradeLogs < ActiveRecord::Migration[8.0]
  def change
    add_reference :trade_logs, :stock, null: false, foreign_key: true
  end
end
