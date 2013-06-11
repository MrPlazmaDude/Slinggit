class ViolationRecords < ActiveRecord::Migration
  def up
    create_table :violation_records do |t|
      t.integer :user_id
      t.string :violation
      t.string :violation_source
      t.integer :violation_source_id
      t.string :action_taken
      t.timestamps
    end
  end

  def down
    drop_table :violation_records
  end
end
