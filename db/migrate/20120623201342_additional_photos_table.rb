class AdditionalPhotosTable < ActiveRecord::Migration
  def up
    create_table :additional_photos do |t|
      t.integer :user_id
      t.string :source
      t.integer :source_id
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at
      t.string :status
    end
  end

  def down
    drop_table :additional_photos
  end
end
