# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class CreateCheckLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :check_logs do |t|
      t.references :check, foreign_key: true
      t.text :raw_response
      t.integer :exit_status
      t.text :parsed_response
      t.text :error
      t.integer :status

      t.timestamps
    end
  end
end
