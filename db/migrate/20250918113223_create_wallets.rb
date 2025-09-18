class CreateWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :wallets do |t|
      t.timestamps
      t.references :user, null: false, foreign_key: true
      t.decimal "balance", null: false
    end
  end
end
