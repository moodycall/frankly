class CreateAvailabilityIntervals < ActiveRecord::Migration
  def change
    create_table :availability_intervals do |t|
      t.integer  :day_of_week, :default => 1, :null => false
      t.integer  :counselor_id
      t.string   :start_time
      t.string   :end_time

      t.timestamps
    end
  end
end
