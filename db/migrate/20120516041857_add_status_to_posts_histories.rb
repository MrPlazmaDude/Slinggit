class AddStatusToPostsHistories < ActiveRecord::Migration
  def change
  	add_column :post_histories, :status, :string
  end
end
