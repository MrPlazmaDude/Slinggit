class PasswordResetCodeForUsers < ActiveRecord::Migration
  def up
    add_column :users, :password_reset_code, :string
  end

  def down
    remove_column :users, :password_reset_code
  end
end
