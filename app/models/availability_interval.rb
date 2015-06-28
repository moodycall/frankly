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

	def start_time_in_counselors_zone(date)
		time = DateTime.parse(start_time)

		DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.zone).in_time_zone(timezone_name)
	end

	def end_time_in_counselors_zone(date)
		time = DateTime.parse(end_time) - 30.minutes

		DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.zone).in_time_zone(timezone_name) + 1.day
	end

	def start_time_in_zone(timezone)
		start_time_in_counselors_zone.in_time_zone(timezone)
	end

	def end_time_in_zone(timezone)
		end_time_in_counselors_zone.in_time_zone(timezone)
	end

	def availabilities(requested_date)
		array = []
		requested_date.beginning_of_day
		requested_date.end_of_day

		origin = requested_date.beginning_of_day

		(0..46).each do |step|
			origin += 30.minutes

			convertion_dts = origin.in_time_zone(timezone_name)

			if convertion_dts.wday == day_of_week and
				 convertion_dts.between?(start_time_in_counselors_zone(convertion_dts), end_time_in_counselors_zone(convertion_dts)) and
				 convertion_dts > (Time.now.in_time_zone(timezone_name) + 30.minutes)

				array.push(origin)
			end
		end

		array
	end

	def self.all_availabilities(requested_date)
		array = []
		self.all.each do |interval|
			if interval.availabilities(requested_date).present?
				array += interval.availabilities(requested_date)
			end
		end
		array
	end

	def self.sundays_availability
		self.where(:day_of_week => 0)
	end

	def self.mondays_availability
		self.where(:day_of_week => 1)
	end

	def self.mondays_availability
		self.where(:day_of_week => 2)
	end

	def self.mondays_availability
		self.where(:day_of_week => 3)
	end

	def self.mondays_availability
		self.where(:day_of_week => 4)
	end

	def self.mondays_availability
		self.where(:day_of_week => 5)
	end

	def self.mondays_availability
		self.where(:day_of_week => 6)
	end

	def self.mondays_availability
		self.where(:day_of_week => 7)
	end

end
