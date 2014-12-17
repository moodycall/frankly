class Rating < ActiveRecord::Base
	belongs_to :rater,    polymorphic: true
	belongs_to :rateable, polymorphic: true
	belongs_to :counseling_session
end
