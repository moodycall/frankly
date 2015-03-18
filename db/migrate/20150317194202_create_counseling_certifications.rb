class CreateCounselingCertifications < ActiveRecord::Migration
  def change
    create_table :counseling_certifications do |t|
      t.string   :name
      t.integer  :counselor_id

      t.timestamps
    end
  end
end
