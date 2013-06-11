class RealTwitterPostTable < ActiveRecord::Migration
  def change
    remove_column :posts, :api_account_id
    remove_column :posts, :post_id
    remove_column :posts, :last_result
    remove_column :posts, :status
    add_column :posts, :recipient_api_account_ids, :string

    create_table :twitter_posts do |t|
      t.integer :user_id
      t.integer :api_account_id
      t.integer :post_id
      t.string :content
      t.string :twitter_post_id
      t.string :status, :default => 'new'
      t.string :last_result, :default => 'no attempt'
      t.timestamps
    end
  end
end
