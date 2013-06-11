class AddMobileRememberMeTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_remember_token, :string
  end
end
