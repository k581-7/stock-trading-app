class AddReferencesToPortfolio < ActiveRecord::Migration[8.0]
  def change
    add_reference :portfolios, :user, null: false, foreign_key: true
    add_reference :portfolios, :stock, null: false, foreign_key: true
  end
end
