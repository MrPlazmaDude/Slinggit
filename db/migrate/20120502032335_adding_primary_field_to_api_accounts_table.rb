class AddingPrimaryFieldToApiAccountsTable < ActiveRecord::Migration
  def change
    add_column :api_accounts, :primary, :boolean, :default => false
  end
end
