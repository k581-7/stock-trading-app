class TradeLog < ApplicationRecord
  self.inheritance_column = nil  # disables STI behavior on `transaction_type` column

  validates :transaction_type, presence: true, inclusion: { in: %w[buy sell deposit withdraw] }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :amount, presence: true, numericality: { greater_than: 0 }

  # Updated scope names to reflect new model name
  scope :buys, -> { where(transaction_type: "buy") }
  scope :sells, -> { where(transaction_type: "sell") }
  scope :deposits, -> { where(transaction_type: "deposit") }
  scope :withdrawals, -> { where(transaction_type: "withdraw") }

  # Updated method name to avoid confusion with old model
  def self.total_amount_by_log_type(log_type)
    where(transaction_type: log_type).sum(:amount)
  end
end