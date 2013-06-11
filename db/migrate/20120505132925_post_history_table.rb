class PostHistoryTable < ActiveRecord::Migration
  def up
    if not ActiveRecord::Base.connection.table_exists? 'post_histories'
      create_table :post_histories, :id => false do |t|
        t.integer :id
        t.string :content
        t.datetime :created_at
        t.string :hashtag_prefix
        t.string :location
        t.boolean :open
        t.string :photo_content_type
        t.string :photo_file_name
        t.integer :photo_file_size
        t.datetime :photo_updated_at
        t.decimal :price
        t.string :recipient_api_account_ids
        t.datetime :updated_at
        t.integer :user_id
      end
    end
  end

  def down
    if ActiveRecord::Base.connection.table_exists? 'post_history'
      drop_table :post_history
    end

    if ActiveRecord::Base.connection.table_exists? 'post_histories'
      drop_table :post_histories
    end
  end
end
