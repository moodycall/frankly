class AddCancelledOnDtsToCounselingSessions < ActiveRecord::Migration
  def change
    add_column :counseling_sessions, :cancelled_on_dts, :datetime
  end
end
