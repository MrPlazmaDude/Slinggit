class RemovePrimaryAccountColumn < ActiveRecord::Migration
  def change
    remove_column :api_accounts, :primary_account
  end
end
