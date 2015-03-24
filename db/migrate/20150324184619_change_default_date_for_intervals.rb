class ChangeDefaultDateForIntervals < ActiveRecord::Migration
  def change
    change_column :counselors, :available_monday, :boolean, :default => false
    change_column :counselors, :available_tuesday, :boolean, :default => false
    change_column :counselors, :available_wednesday, :boolean, :default => false
    change_column :counselors, :available_thursday, :boolean, :default => false
    change_column :counselors, :available_friday, :boolean, :default => false
  end
end
