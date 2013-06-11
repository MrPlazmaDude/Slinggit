class AddIdHashToPostHistory < ActiveRecord::Migration
  def up
    add_column :post_histories, :id_hash, :string
  end

  def down
    remove_column :post_histories, :id_hash
  end
end
