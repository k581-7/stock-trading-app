class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  before_update :set_approval_date, if: :saved_change_to_approved?

  private

  def set_approval_date
    if approved?
      self.approval_date = Time.current
    else
      self.approval_date = nil
    end
  end
end
