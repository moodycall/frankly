class AvailabilityDay < ActiveRecord::Base
	belongs_to :counselor
	belongs_to :availability_dates
end