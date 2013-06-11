class RemovingMobileRememberTokenToSupportAllDevicesWithState < ActiveRecord::Migration
  def change
    remove_column :users, :mobile_remember_token

    create_table :mobile_sessions do |t|
      t.integer :user_id
      t.string :unique_identifier
      t.string :mobile_auth_token
      t.timestamps
    end
  end
end
