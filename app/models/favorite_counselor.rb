class FavoriteCounselor < ActiveRecord::Base
	belongs_to :user
	belongs_to :counselor

	validates_uniqueness_of :counselor, :scope => :user
end
