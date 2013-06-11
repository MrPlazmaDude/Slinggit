class CreateFlaggedContentsTable < ActiveRecord::Migration
  def up
    create_table :flagged_contents do |t|
      t.integer :creator_user_id
      t.string :content_source
      t.integer :content_id
      t.timestamps
    end
  end

  def down
    drop_table :flagged_contents
  end
end
