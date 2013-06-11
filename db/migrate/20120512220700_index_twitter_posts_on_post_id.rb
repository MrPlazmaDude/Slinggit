class IndexTwitterPostsOnPostId < ActiveRecord::Migration
  def change
  	add_index :twitter_posts, :post_id
  end
end
