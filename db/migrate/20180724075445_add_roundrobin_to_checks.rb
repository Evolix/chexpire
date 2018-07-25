# Copyright (C) 2018 Juliette Cougnoux <jcougnoux@evolix.fr>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)
class AddRoundrobinToChecks < ActiveRecord::Migration[5.2]
  def change
    add_column :checks, :round_robin, :boolean, default: true
  end
end
