class ChangePrimaryToPrimaryAccount < ActiveRecord::Migration
  def change
    rename_column :api_accounts, :primary, :primary_account
  end
end
