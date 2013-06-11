class ApiAccountsTable < ActiveRecord::Migration
  def change
    create_table :api_accounts do |t|
      t.integer :user_id
      t.string :api_id
      t.string :api_id_hash
      t.string :api_source
      t.string :oauth_token
      t.string :oauth_secret
      t.string :real_name
      t.string :user_name
      t.string :image_url
      t.string :description
      t.string :language
      t.string :location
      t.string :status
      t.timestamps
    end
  end
end
