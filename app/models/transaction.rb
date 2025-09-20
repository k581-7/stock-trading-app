class Transaction < ApplicationRecord
  self.inheritance_column = nil
  
  validates :type, presence: true, inclusion: { in: %w[buy sell deposit withdraw] }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  
  scope :buy_transactions, -> { where(type: 'buy') }
  scope :sell_transactions, -> { where(type: 'sell') }
  scope :deposit_transactions, -> { where(type: 'deposit') }
  scope :withdraw_transactions, -> { where(type: 'withdraw') }
  
  def self.total_amount_by_type(transaction_type)
    where(type: transaction_type).sum(:amount)
  end
end