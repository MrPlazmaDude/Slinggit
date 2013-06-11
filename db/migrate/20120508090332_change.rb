class Change < ActiveRecord::Migration
  def up
    rename_column :user_limitations, :limit, :user_limit
  end

  def down
    rename_column :user_limitations, :user_limit, :limit
  end
end
