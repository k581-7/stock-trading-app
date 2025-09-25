class Stock < ApplicationRecord
  has_many :portfolios, dependent: :destroy
  has_many :users, through: :portfolios

  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true
  validates :current_price, numericality: { greater_than_or_equal_to: 0 }

  def profit_margin
    selling_price - buying_price
  end

    def last_updated?
    last_updated_at.present?
  end

  def profit_percentage
    return 0 if buying_price.zero?
    ((selling_price - buying_price) / buying_price * 100).round(2)
  end
end
