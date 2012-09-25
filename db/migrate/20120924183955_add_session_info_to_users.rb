class AddSessionInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registered_on, :timestamp
    add_column :users, :last_login, :timestamp
  end
end
