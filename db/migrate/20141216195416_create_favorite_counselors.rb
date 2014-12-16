class CreateFavoriteCounselors < ActiveRecord::Migration
  def change
    create_table :favorite_counselors do |t|
      t.integer  :user_id
      t.integer  :counselor_id

      t.timestamps
    end
  end
end
