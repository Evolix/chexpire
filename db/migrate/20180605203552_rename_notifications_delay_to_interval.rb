# Copyright (C) 2018 Colin Darie <colin@darie.eu>, Jeremy Lecour <jlecour@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class RenameNotificationsDelayToInterval < ActiveRecord::Migration[5.2]
  def change
    rename_column :notifications, :delay, :interval
  end
end
