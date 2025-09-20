class Stock < ApplicationRecord
  has_many :portfolios, dependent: :destroy
  has_many :users, through: :portfolios
  
  validates :title, presence: true
  validates :buying_price, presence: true, numericality: { greater_than: 0 }
  validates :selling_price, presence: true, numericality: { greater_than: 0 }
  
  def profit_margin
    selling_price - buying_price
  end
  
  def profit_percentage
    return 0 if buying_price.zero?
    ((selling_price - buying_price) / buying_price * 100).round(2)
  end
end