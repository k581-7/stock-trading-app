class Wallet < ApplicationRecord
  belongs_to :user

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: true, presence: true

  def can_withdraw?(amount)
    balance >= amount
  end

  def deposit(amount)
    return false if amount <= 0
    self.balance += amount
    save
  end

  def withdraw(amount)
    return false unless can_withdraw?(amount)
    self.balance -= amount
    save
  end

  def sufficient_funds_for_purchase?(total_cost)
    balance >= total_cost
  end
end
