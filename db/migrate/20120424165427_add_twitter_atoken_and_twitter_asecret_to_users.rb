class AddTwitterAtokenAndTwitterAsecretToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :twitter_atoken, :string
  	add_column :users, :twitter_asecret, :string
  end
end
