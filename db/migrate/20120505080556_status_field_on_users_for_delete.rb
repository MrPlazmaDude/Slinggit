class StatusFieldOnUsersForDelete < ActiveRecord::Migration
  def up
    add_column :users, :status, :string, :default => 'active'
    remove_column :users, :twitter_asecret
    remove_column :users, :twitter_atoken
  end

  def down
    remove_column :users, :status
    add_column :users, :twitter_asecret, :string
    add_column :users, :twitter_atoken, :string
  end
end
