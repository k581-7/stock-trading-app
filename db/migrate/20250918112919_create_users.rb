class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.timestamps
      t.string "username", null: false
      t.string "email", null: false
      t.string "password", null: false
      t.date "approval_date", null: false
      t.boolean "is_admin", default: false
      t.boolean "is_broker", default: false
    end
  end
end
