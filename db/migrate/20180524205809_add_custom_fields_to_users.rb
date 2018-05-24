class AddCustomFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tos_accepted, :boolean, null: false, default: false
    add_column :users, :notifications_enabled, :boolean, null: false, default: true
  end
end
