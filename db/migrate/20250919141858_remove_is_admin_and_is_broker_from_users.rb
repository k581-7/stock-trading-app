class RemoveIsAdminAndIsBrokerFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :is_admin, :boolean
    remove_column :users, :is_broker, :boolean
  end
end
