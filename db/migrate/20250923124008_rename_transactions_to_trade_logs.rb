class RenameTransactionsToTradeLogs < ActiveRecord::Migration[8.0]
  def change
    rename_table :transactions, :trade_logs
  end
end
