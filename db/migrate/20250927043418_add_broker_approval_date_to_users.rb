class AddBrokerApprovalDateToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :broker_approval_date, :datetime
  end
end
