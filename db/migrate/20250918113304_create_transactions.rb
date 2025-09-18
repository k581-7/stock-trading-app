class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.timestamps
      # t.references :user, null: false, foreign_key: true
      # t.references :stock, null: false, foreign_key: true
      # t.string "type", null: false
      # t.decimal "quantity", null: false
      # t.decimal "amount", null: false
    end
  end
end
