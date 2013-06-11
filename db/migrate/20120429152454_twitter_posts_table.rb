class TwitterPostsTable < ActiveRecord::Migration
  def change
    add_column :posts, :api_account_id, :integer, :after => 'id'
    add_column :posts, :post_id, :string
    add_column :posts, :last_result, :string
  end
end
