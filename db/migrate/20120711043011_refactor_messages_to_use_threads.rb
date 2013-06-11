class RefactorMessagesToUseThreads < ActiveRecord::Migration
  def up
    add_column :messages, :thread_id, :string
    add_column :messages, :recipient_status, :string
    add_column :messages, :sender_status, :string

    rename_column :messages, :creator_user_id, :sender_user_id
    rename_column :messages, :parent_source_id, :parent_id
  end

  def down
    remove_column :messages, :recipient_status
    remove_column :messages, :sender_status
    remove_column :messages, :thread_id

    rename_column :messages, :sender_user_id, :creator_user_id
    rename_column :messages, :parent_id, :parent_source_id
  end
end
