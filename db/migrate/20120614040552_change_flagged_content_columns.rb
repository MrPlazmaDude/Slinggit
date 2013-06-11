class ChangeFlaggedContentColumns < ActiveRecord::Migration
  def up
    rename_column :flagged_contents, :content_source, :source
    rename_column :flagged_contents, :content_id, :source_id
  end

  def down
  end
end
