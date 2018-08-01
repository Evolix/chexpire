# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class RenameChecksDomainExpireAtToDomainExpiresAt < ActiveRecord::Migration[5.2]
  def change
    rename_column :checks, :domain_expire_at, :domain_expires_at
  end
end
