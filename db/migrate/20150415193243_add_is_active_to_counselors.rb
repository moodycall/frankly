class AddIsActiveToCounselors < ActiveRecord::Migration
  def change
    add_column :counselors, :is_active, :boolean, :default => false, :null => false
  end
end
