class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  enum :role, { admin: 0, trader: 1, broker: 2 }

  before_create :set_default_role
  before_update :set_approval_date, if: :will_save_change_to_role?

  def approved?
    broker? || admin?
  end

  private

  def set_default_role
    self.role ||= :trader
  end

  def set_approval_date
    self.approval_date = approved? ? Time.current : nil
  end
end
