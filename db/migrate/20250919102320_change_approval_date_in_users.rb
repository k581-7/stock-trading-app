class ChangeApprovalDateInUsers < ActiveRecord::Migration[8.0]
  def change
    change_column :users, :approval_date, :datetime, null: true
  end
end
