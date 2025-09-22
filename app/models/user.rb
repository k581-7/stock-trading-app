class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  enum :role, { admin: 0, trader: 1, broker: 2 }

  after_update :set_approval_date, if: :saved_change_to_role?


  def approved?
    broker? || admin?
  end

  private

  def set_default_role
    self.role ||= :trader
  end

  def set_approval_date
    if approved?
      self.approval_date = Time.current
    else
      self.approval_date = nil
    end
  end
end
