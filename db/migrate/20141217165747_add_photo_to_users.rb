class AddPhotoToUsers < ActiveRecord::Migration
  def change
  	add_column    :users,      :photo, :string
  	remove_column :counselors, :photo, :string
  end
end
