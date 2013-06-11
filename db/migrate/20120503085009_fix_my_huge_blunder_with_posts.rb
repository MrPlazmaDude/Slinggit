class FixMyHugeBlunderWithPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :recipient_api_account_ids
    add_column :api_accounts, :reauth_required, :string, :default => 'no'

    add_column :posts, :status, :string, :default => 'active'

    drop_table :api_account_post_statuses
  end
end
