class AddHashtagAndPriceToPost < ActiveRecord::Migration
  def change
  	add_column :posts, :hashtag_prefix, :string
  	add_column :posts, :price, :decimal, :precision => 8, :scale => 2
  end
end
