class AccountReactiveCodeForUsers < ActiveRecord::Migration
  def up
    add_column :users, :account_reactivation_code, :string

    create_table :user_feedbacks do |t|
      t.integer :user_id
      t.string :source
      t.text :information
      t.timestamps
    end
  end

  def down
    drop_table :user_feedbacks
    remove_column :users, :account_reactivation_code
  end
end
