class ChangeStatusDefaultForUser < ActiveRecord::Migration
  def up
  	change_column_default(:users, :status, 'unverified')
  end

  def down
  	change_column_default(:users, :status, 'active')
  end
end
