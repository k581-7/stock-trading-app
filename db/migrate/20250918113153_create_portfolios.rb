class CreatePortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolios do |t|
      t.timestamps
      # t.references :user, null: false, foreign_key: true
      # t.references :stock, null: false, foreign_key: true
    end
  end
end
