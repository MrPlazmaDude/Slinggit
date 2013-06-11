class Messages < ActiveRecord::Migration
  def up
    create_table :messages do |t|
      t.integer :creator_user_id
      t.integer :recipient_user_id
      t.string :source
      t.integer :source_id
      t.string :contact_info_json
      t.string :body, :limit => 1200
      t.string :status, :default => 'UNR'
      t.string :id_hash
      t.timestamps
    end

    add_index :messages, :creator_user_id
    add_index :messages, :source
    add_index :messages, :status
    add_index :messages, :id_hash
  end

  def down
    drop_table :messages
  end
end
