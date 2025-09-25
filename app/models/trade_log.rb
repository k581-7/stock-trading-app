# app/models/trade_log.rb
class TradeLog < ApplicationRecord
  self.inheritance_column = nil

  VALID_TYPES = %w[buy sell deposit withdraw].freeze
  before_validation :default_qty_for_cash_ops

  validates :transaction_type, presence: true, inclusion: { in: VALID_TYPES }
  validates :amount, presence: true, numericality: { greater_than: 0 }

  validates :quantity, presence: true, numericality: { greater_than: 0 },
           if: -> { %w[buy sell].include?(transaction_type) }

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 },
           if: -> { %w[deposit withdraw].include?(transaction_type) }

  private

  def default_qty_for_cash_ops
    self.quantity = 0 if %w[deposit withdraw].include?(transaction_type) && quantity.nil?
  end
end
