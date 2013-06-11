class Redirects < ActiveRecord::Migration
  def up
    create_table :redirects do |t|
      t.string :key_code
      t.string :target_uri
      t.integer :clicks, :default => 0
      t.boolean :active, :default => true
      t.timestamps
    end
  end

  def down
    drop_table :redirects
  end
end

