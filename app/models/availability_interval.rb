class AvailabilityInterval < ActiveRecord::Base
	include ActionView::Helpers
	
	belongs_to :counselor

	DAY_SUNDAY    = 0
	DAY_MONDAY    = 1
	DAY_TUESDAY   = 2
	DAY_WEDNESDAY = 3
	DAY_THURSDAY  = 4
	DAY_FRIDAY    = 5
	DAY_SATURDAY  = 6

	def self.days_of_the_week
		{
      DAY_MONDAY    => "Monday",
		  DAY_TUESDAY   => "Tuesday",
		  DAY_WEDNESDAY => "Wednesday",
		  DAY_THURSDAY  => "Thursday",
		  DAY_FRIDAY    => "Friday",
		  DAY_SATURDAY  => "Saturday",
		  DAY_SUNDAY    => "Sunday"
    }
	end
end
