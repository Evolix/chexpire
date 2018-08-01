# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class AddCustomFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tos_accepted, :boolean, null: false, default: false
    add_column :users, :notifications_enabled, :boolean, null: false, default: true
  end
end
