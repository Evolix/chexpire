class RenameChecksDomainExpireAtToDomainExpiresAt < ActiveRecord::Migration[5.2]
  def change
    rename_column :checks, :domain_expire_at, :domain_expires_at
  end
end
