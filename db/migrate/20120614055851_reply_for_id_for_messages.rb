class ReplyForIdForMessages < ActiveRecord::Migration
  def up
    add_column :messages, :parent_source_id, :integer
  end

  def down
    remove_column :messages, :parent_source_id
  end
end
