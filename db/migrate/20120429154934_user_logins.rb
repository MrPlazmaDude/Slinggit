class UserLogins < ActiveRecord::Migration
  def change
    create_table :user_logins do |t|
      t.integer :user_id
      t.string :user_agent
      t.string :ip_address
      t.string :url_referrer
      t.string :login_source
      t.timestamps
    end
  end
end
