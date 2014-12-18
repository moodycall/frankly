class CreateSpecializations < ActiveRecord::Migration
  def change
    create_table :specializations do |t|
      t.integer  :specialty_id
      t.integer  :counselor_id

      t.timestamps
    end
  end
end
