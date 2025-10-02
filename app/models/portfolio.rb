class Portfolio < ApplicationRecord
  belongs_to :user
  belongs_to :stock

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :user_id, uniqueness: { scope: :stock_id, message: "can only have one portfolio per stock" }
  validates :stock_id, presence: true

  def total_buying_value
    quantity * stock.current_price.to_f
  end

  def total_selling_value
    quantity * stock.current_price.to_f
  end

  def profit_loss
    total_selling_value - total_buying_value
  end

  def profit_loss_percentage
    return 0 if total_buying_value.zero?
    ((profit_loss / total_buying_value) * 100).round(2)
  end
end
