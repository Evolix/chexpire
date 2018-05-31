class CreateChecks < ActiveRecord::Migration[5.2]
  def change
    create_table :checks do |t|
      t.references :user, foreign_key: true
      t.integer :kind, null: false
      t.string :domain, null: false
      t.datetime :domain_created_at
      t.datetime :domain_updated_at
      t.datetime :domain_expire_at
      t.datetime :last_run_at
      t.datetime :last_success_at
      t.string :vendor
      t.string :comment
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
