class CreateWatchedposts < ActiveRecord::Migration
  def change
    create_table :watchedposts do |t|
      t.integer :post_id
      t.integer :user_id

      t.timestamps
    end
    add_index :watchedposts, [:user_id, :post_id], :unique => true, :name => 'by_user_and_post'
    add_index :watchedposts, [:created_at]
  end
end
