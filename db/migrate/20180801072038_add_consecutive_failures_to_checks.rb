# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class AddConsecutiveFailuresToChecks < ActiveRecord::Migration[5.2]
  def change
    add_column :checks, :consecutive_failures, :integer, default: 0, null: false
  end
end
