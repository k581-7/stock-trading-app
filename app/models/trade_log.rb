class TradeLog < ApplicationRecord
  belongs_to :user
  belongs_to :stock, optional: true
  belongs_to :wallet, optional: true
  self.inheritance_column = nil
  VALID_TYPES = %w[buy sell deposit withdraw].freeze
  before_validation :default_qty_for_cash_ops
  validates :transaction_type, presence: true, inclusion: { in: VALID_TYPES }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0 },
           if: -> { %w[buy sell].include?(transaction_type) }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 },
           if: -> { %w[deposit withdraw].include?(transaction_type) }
  scope :buys, -> { where(transaction_type: "buy") }
  scope :sells, -> { where(transaction_type: "sell") }
  scope :deposits, -> { where(transaction_type: "deposit") }
  scope :withdrawals, -> { where(transaction_type: "withdraw") }
  scope :for_user, ->(user) { where(user: user) }
  def self.total_amount_by_log_type(type)
    where(transaction_type: type).sum(:amount)
  end
  private
  def default_qty_for_cash_ops
    self.quantity = 0 if %w[deposit withdraw].include?(transaction_type) && quantity.nil?
  end
end