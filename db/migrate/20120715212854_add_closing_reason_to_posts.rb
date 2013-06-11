class AddClosingReasonToPosts < ActiveRecord::Migration
  def up
    add_column :post_histories, :closing_reason, :string
    add_column :posts, :closing_reason, :string
  end

  def down
    remove_column :post_histories, :closing_reason
    remove_column :posts, :closing_reason
  end
end