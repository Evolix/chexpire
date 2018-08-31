# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class RemoveObsoleteFieldsToNotifications < ActiveRecord::Migration[5.2]
  def change
    remove_column :notifications, :status, :integer, null: false, limit: 1, default: 0
    remove_column :notifications, :sent_at, :datetime
  end
end
