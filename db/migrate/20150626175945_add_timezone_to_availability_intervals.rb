class AddTimezoneToAvailabilityIntervals < ActiveRecord::Migration
  def change
    add_column :availability_intervals, :timezone_name, :string
  end
end
