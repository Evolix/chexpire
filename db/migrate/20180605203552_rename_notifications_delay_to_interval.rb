class RenameNotificationsDelayToInterval < ActiveRecord::Migration[5.2]
  def change
    rename_column :notifications, :delay, :interval
  end
end
