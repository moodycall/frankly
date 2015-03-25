class ChangeDefaultCounselorValue < ActiveRecord::Migration
  def up
    change_column :counselors, :hourly_fee_in_cents, :integer, :default => 750
  end

  def down
    change_column :counselors, :hourly_fee_in_cents, :integer, :default => 600
  end
end
