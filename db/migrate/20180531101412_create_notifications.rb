class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :check, foreign_key: true
      t.integer :channel, null: false, default: 0
      t.string :recipient, null: false
      t.integer :delay, null: false
      t.integer :status, null: false, default: 0
      t.datetime :sent_at

      t.timestamps
    end
  end
end
