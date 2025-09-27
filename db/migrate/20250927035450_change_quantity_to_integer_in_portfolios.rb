class ChangeQuantityToIntegerInPortfolios < ActiveRecord::Migration[8.0]
  def change
    change_column :portfolios, :quantity, :integer, using: 'quantity::integer'
  end
end
