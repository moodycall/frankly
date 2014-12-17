class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer  :rater_id,      :null => false
      t.string   :rater_type,    :null => false
      t.integer  :rateable_id,   :null => false
      t.string   :rateable_type, :null => false
      t.text     :comment
      t.integer  :stars,         :null => false
      t.integer  :counseling_session_id

      t.timestamps
    end

    add_index :ratings, [:rater_id, :rater_type]
    add_index :ratings, [:rateable_id, :rateable_type]
  end
end
