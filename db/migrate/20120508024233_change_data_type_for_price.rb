class ChangeDataTypeForPrice < ActiveRecord::Migration
  def up
  	change_table :posts do |t|
      t.change :price, :integer
    end
  end

  def down
  	change_table :posts do |t|
      t.change :price, :decimal
    end
  end
end
