class AddLocaleToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :locale, :string, null: false, default: "en", limit: 5
  end
end
