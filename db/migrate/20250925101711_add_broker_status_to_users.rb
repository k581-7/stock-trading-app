class AddBrokerStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :broker_status, :integer, default: 0
  end
end
