class AddLicenseTypeToCounselingLicense < ActiveRecord::Migration
  def change
    add_column :counseling_licenses, :license_type, :string
  end
end
