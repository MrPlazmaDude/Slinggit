class AddStatusToPosts < ActiveRecord::Migration
  def change
  	add_column :posts, :status, :string, :default => 'active'
  end
end
