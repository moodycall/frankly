class Specialty < ActiveRecord::Base
	extend FriendlyId
  friendly_id :name, use: [:slugged, :history, :finders]

	has_many :specializations
	has_many :counselors, :through => :specializations
end
