class RenameTypeColumnInTradeLogs < ActiveRecord::Migration[8.0]
  def change
    rename_column :trade_logs, :type, :transaction_type
  end
end
