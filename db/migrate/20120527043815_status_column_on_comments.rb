class StatusColumnOnComments < ActiveRecord::Migration
  def up
    add_column :comments, :status, :string, :default => 'active'
  end

  def down
    remove_column :comments, :status
  end
end
