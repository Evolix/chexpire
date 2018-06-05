class RenameNotificationsintervalToInterval < ActiveRecord::Migration[5.2]
  def change
    rename_column :notifications, :interval, :interval
  end
end
