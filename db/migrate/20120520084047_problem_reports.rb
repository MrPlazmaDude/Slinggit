class ProblemReports < ActiveRecord::Migration
  def up
    create_table :problem_reports do |t|
      t.string :exception_message
      t.string :exception_class
      t.text :exception_backtrace
      t.string :user_agent
      t.string :ip_address
      t.string :url_referrer
      t.integer :signed_in_user_id
      t.string :status, :default => 'open'
      t.integer :last_updated_by_user_id
      t.integer :owned_by_user_id
      t.timestamps
    end
  end

  def down
    drop_table :problem_reports
  end
end
