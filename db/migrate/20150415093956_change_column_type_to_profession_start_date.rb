class ChangeColumnTypeToProfessionStartDate < ActiveRecord::Migration
  def up
    change_column :counselors, :profession_start_date, :string
  end

  def down
    change_column :counselors, :profession_start_date, :date
  end
end
