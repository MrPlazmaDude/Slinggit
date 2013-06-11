class NewColumnsForUserLogins < ActiveRecord::Migration
  def change
    add_column :user_logins, :session_json, :string, :limit => 500
    add_column :user_logins, :paramaters_json, :string, :limit => 500
  end
end
