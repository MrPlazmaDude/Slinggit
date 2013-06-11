class UserLimitationsTable < ActiveRecord::Migration
  def up
    create_table :user_limitations do |t|
      t.integer :user_id
      t.string :limitation_type
      t.integer :limit
      t.integer :frequency
      t.string :frequency_type
      t.boolean :active, :default => true
      t.timestamps
    end
  end

  def down
    drop_table :user_limitations
  end
end
