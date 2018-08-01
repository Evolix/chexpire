class AddConsecutiveFailuresToChecks < ActiveRecord::Migration[5.2]
  def change
    add_column :checks, :consecutive_failures, :integer, default: 0, null: false
  end
end
