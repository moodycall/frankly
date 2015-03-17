class CreateCounselingLicenses < ActiveRecord::Migration
  def change
    create_table :counseling_licenses do |t|
      t.string   :license_number
      t.string   :state
      t.date     :established_on_date
      t.integer  :counselor_id

      t.timestamps
    end
  end
end
