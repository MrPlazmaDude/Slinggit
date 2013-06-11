class TokenExpirationForApiAccounts < ActiveRecord::Migration
  def up
    add_column :api_accounts, :oauth_expiration, :datetime
  end

  def down
    remove_column :api_accounts, :oauth_expiration
  end
end
