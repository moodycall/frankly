class CreateCounselingDegrees < ActiveRecord::Migration
  def change
    create_table :counseling_degrees do |t|
      t.integer  :counselor_id
      t.string   :degree_type
      t.string   :name
      t.string   :institution
      t.string   :year_of_completion

      t.timestamps
    end
  end
end
