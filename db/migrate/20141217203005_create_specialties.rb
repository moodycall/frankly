class CreateSpecialties < ActiveRecord::Migration
  def change
    create_table :specialties do |t|
      t.string   :name
      t.string   :slug
      t.boolean  :is_active, :default => false, :null => false

      t.timestamps
    end
  end
end
