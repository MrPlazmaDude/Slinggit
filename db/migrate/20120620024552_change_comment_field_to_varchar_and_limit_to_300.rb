class ChangeCommentFieldToVarcharAndLimitTo300 < ActiveRecord::Migration
  def up
    change_column(:comments, :body, :string, :limit => 350)
  end

  def down
    change_column(:comments, :body, :text)
  end
end
