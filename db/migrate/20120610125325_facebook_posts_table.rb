class FacebookPostsTable < ActiveRecord::Migration
  def up
    create_table :facebook_posts do |t|
      t.integer :user_id
      t.integer :api_account_id
      t.integer :post_id
      t.string :name #name
      t.string :message #message
      t.string :caption #caption
      t.string :description #description
      t.string :image_url #picture
      t.string :link_url #link
      t.string :facebook_post_id
      t.string :status
      t.string :last_result
      t.timestamps
    end
  end

  def down
    drop_table :facebook_posts
  end
end
