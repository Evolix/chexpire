# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class CreateCheckNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :check_notifications do |t|
      t.references :check, foreign_key: true
      t.references :notification, foreign_key: true
      t.integer :status, null: false, default: 0, limit: 1
      t.datetime :sent_at

      t.timestamps
    end
  end
end
