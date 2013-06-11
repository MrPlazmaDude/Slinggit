# == Schema Information
#
# Table name: system_preferences
#
#  id               :integer         not null, primary key
#  preference_key   :string(255)
#  preference_value :string(255)
#  constraints      :string(255)
#  description      :string(255)
#  start_date       :datetime
#  end_date         :datetime
#  active           :boolean         default(FALSE)
#

#create_table :system_preferences do |t|
#  t.string :preference_key
#  t.string :preference_value
#  t.string :constraints
#  t.string :descripion
#  t.datetime :start_date
#  t.datetime :end_date
#  t.boolean :active, :default => false
#end

class SystemPreference < ActiveRecord::Base
  attr_accessible :preference_key, :preference_value, :constraints, :description, :start_date, :end_date, :active

  def is_active?
    self.status == 'active'
  end
end
