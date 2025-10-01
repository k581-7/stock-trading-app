# app/models/user.rb
class User < ApplicationRecord
  # --- Devise modules ---
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # --- Enums ---
  enum :role, { admin: 0, trader: 1, broker: 2 }
  enum :broker_status, { no_application: 0, broker_pending: 1, broker_approved: 2, broker_rejected: 3 }

  # --- Associations ---
  has_one  :wallet,     dependent: :destroy
  has_many :portfolios, dependent: :destroy
  has_many :stocks, through: :portfolios
  has_many :trade_logs, dependent: :destroy

  # --- Callbacks ---
  after_create :ensure_wallet!
  before_create :set_default_role
  before_update :set_approval_date, if: :will_save_change_to_role?

  # --- Instance methods ---
  def approved?
    approved
  end

  def ensure_wallet!
    wallet || create_wallet!(balance: 0)
  end

  def day_profit_loss
    trade_logs.sum do |log|
      next 0 unless log.stock && log.stock.price_change
      direction = log.transaction_type == "buy" ? 1 : -1
      log.stock.price_change.to_f * log.quantity.to_f * direction
    end
  end

  private

  def set_default_role
    self.role ||= :trader
  end

  def set_approval_date
    self.approval_date = approved? ? Time.current : nil
  end
end
