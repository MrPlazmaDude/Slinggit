class AddingPostToFieldsToPostsTable < ActiveRecord::Migration
  def change
    add_column :posts, :recipient_api_account_ids, :string
  end
end
