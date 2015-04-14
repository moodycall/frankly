class ChangeColumnTypeForEstablishedOnDateCounselingLicense < ActiveRecord::Migration
  def up
    change_column :counseling_licenses, :established_on_date, :string
  end

  def down
    change_column :counseling_licenses, :established_on_date, :date
  end
end
