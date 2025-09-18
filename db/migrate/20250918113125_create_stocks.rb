class CreateStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks do |t|
      t.timestamps
      # t.references :portfolio, null: false, foreign_key: true
      t.string "title", null: false
      t.decimal "buying_price", null: false
      t.decimal "selling_price", null: false
    end
  end
end
