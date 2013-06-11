class EmailActivationHashOnUsers < ActiveRecord::Migration
  def up
    add_column :users, :email_activation_code, :string
  end

  def down
    remove_column :users, :email_activation_code
  end
end
