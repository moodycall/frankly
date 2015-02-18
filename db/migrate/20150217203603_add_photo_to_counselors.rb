class AddPhotoToCounselors < ActiveRecord::Migration
  def change
    add_column :counselors, :photo, :string
  end
end
