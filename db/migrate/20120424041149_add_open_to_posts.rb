class AddOpenToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :open, :boolean, default: true
  end
end
