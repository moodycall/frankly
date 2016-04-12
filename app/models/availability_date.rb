class AvailabilityDate < ActiveRecord::Base
	belongs_to :counselor

	has_many :availability_intervals, dependent: :delete_all
	has_many :availability_days, dependent: :delete_all
end
