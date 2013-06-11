class AddLocationToPosts < ActiveRecord::Migration
  def change
  	add_column :posts, :location, :string
  	add_index :posts, :location
  end
end
