class IndexTwitterPostsOnApiAccountId < ActiveRecord::Migration
  def change
  	add_index :twitter_posts, :api_account_id
  end
end
