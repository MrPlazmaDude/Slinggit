class CreateApiAccountPostStatusesTable < ActiveRecord::Migration
  def change
    create_table :api_account_post_statuses do |t|
      t.integer :user_id
      t.string :host_machine
      t.integer :triggering_api_account_id
      t.string :attempted_post_source
      t.integer :attempted_post_id
      t.string :remaining_recipient_api_account_ids
      t.string :status
      t.timestamps
    end
  end
end
