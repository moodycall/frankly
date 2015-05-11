class Counselor < ActiveRecord::Base
	include ActionView::Helpers

	extend FriendlyId
  friendly_id :created_slug, use: [:slugged, :history, :finders]

	belongs_to :user

	has_many :availability_intervals
	has_many :counseling_sessions
	has_many :ratings, as: :rateable
	has_many :specializations
	has_many :specialties, :through => :specializations
	has_many :counseling_licenses
	has_many :counseling_certifications
	has_many :counseling_degrees

	accepts_nested_attributes_for :availability_intervals
	accepts_nested_attributes_for :counseling_licenses
	accepts_nested_attributes_for :counseling_certifications
	accepts_nested_attributes_for :counseling_degrees
	
	validates_presence_of :bio,
												:profession_start_date,
												:photo
												
	before_create :_create_stripe_recipient_id

	mount_uploader :photo, ProfilePhotoUploader

	def created_slug
		self.user.name
	end

	def name_with_identifier
		"#{user_id}  #{user.name}"
	end

	def self.payable_counselors
		counselors = Counselor.select do |counselor|
			counselor.payable_sessions.count > 0
		end
		counselors
	end

	def payable_sessions
		counseling_sessions.select do |session|
			session.estimated_endtime < Time.now and
			session.refund_amount_in_cents == nil and
			session.payout_id.nil?
		end
	end

	def payable_total_in_dollars
		payable_sessions.count * session_net_profit_in_dollars
	end

	def payable_total_in_cents
		(payable_sessions.count * session_net_profit_in_dollars) * 100
	end

	def is_user_favorite(user_id)
		user = User.find(user_id)
		if user.favorite_counselors.where(:counselor_id => self.id).present?
			return true
		else
			return false
		end
	end

	def session_net_profit_in_cents
		(session_net_profit_in_dollars * 100).to_i 
	end
	
	def session_net_profit_in_dollars
		session_rate_in_dollars - session_fee_in_dollars
	end

	def public_rating
		total = 0
		ratings.each do |rating|
			total += rating.stars
		end

		if total == 0
			return 0
		else
			star_count = total / ratings.count
		end
	end

	def popularity
		public_rating * ratings.count
	end

	def hourly_rate_in_dollars
		hourly_rate_in_cents * 0.01
	end

	def hourly_fee_in_dollars
		hourly_fee_in_cents * 0.01
	end

	def session_rate_in_dollars
		hourly_rate_in_dollars / 2
	end

	def session_fee_in_dollars
		hourly_fee_in_dollars / 2
	end

	def minutely_rate_in_cents
		hourly_rate_in_cents / 60
	end

	def years_in_business
		distance_of_time_in_words(profession_start_date, Time.now)
	end

	def booked_session_by_date(date)
    booked_sessions = counseling_sessions.where(start_datetime: Date.parse(date.to_s).beginning_of_day..Date.parse(date.to_s).end_of_day).all
  end

	def availability_by_dts(date)
		if available_on_day(date.wday)
			available_times = []
	    daily_times 	= ["12:00am","12:30am","01:00am","01:30am","02:00am","02:30am","03:00am","03:30am","04:00am","04:30am","05:00am","05:30am","06:00am","06:30am","07:00am","07:30am","08:00am","08:30am","09:00am","09:30am","10:00am","10:30am","11:00am","11:30am","12:00pm","12:30pm","01:00pm","01:30pm","02:00pm","02:30pm","03:00pm","03:30pm","04:00pm","04:30pm","05:00pm","05:30pm","06:00pm","06:30pm","07:00pm","07:30pm","08:00pm","08:30pm","09:00pm","09:30pm","10:00pm","10:30pm","11:00pm","11:30pm"]
	    intervals   	= availability_intervals.where(:day_of_week => date.wday).all

	    intervals.each do |interval|
	    	interval_start		 = parse_dts(interval.start_time).in_time_zone(Time.zone.name)
	    	interval_end  		 = parse_dts(interval.end_time).in_time_zone(Time.zone.name)
	    	interval_start_dts = DateTime.new(date.year, date.month, date.day, interval_start.hour, interval_start.min, interval_start.sec, interval_start.zone)
	    	interval_end_dts   = DateTime.new(date.year, date.month, date.day, interval_end.hour, interval_end.min, interval_end.sec, interval_end.zone)

	    	daily_times.each do |time|
	    		t  						= parse_dts(time).in_time_zone(Time.zone.name)
    			checkable_dts = DateTime.new(date.year, date.month, date.day, t.hour, t.min, t.sec, t.zone).in_time_zone(Time.zone.name)

    			if (checkable_dts).between?(interval_start_dts, (interval_end_dts - 30.minutes)) and checkable_dts > Time.now
    				available_times.push(checkable_dts)
    			end
    		end
    	end

    	booked_session_by_date(date).each do |booked_session|
				all_times = available_times
				if booked_session.estimate_duration_in_minutes == 60
					time_to_remove = [Time.zone.parse("#{booked_session.start_datetime}").utc, Time.zone.parse("#{booked_session.start_datetime + 30.minutes}").utc]
				else
					time_to_remove = [Time.zone.parse("#{booked_session.start_datetime}").utc]
				end

				available_times = all_times.reject{ |e| time_to_remove.include? e }
	    end

			available_times.sort_by{|e| e}
	  else
	  	[]
	  end
	end

	def next_available
		if availability_by_dts(Time.now).count > 0
			availability_by_dts(Time.now).first

		elsif availability_by_dts(Time.now + 1.day).count > 0
			availability_by_dts(Time.now + 1.day).first

		elsif availability_by_dts(Time.now + 2.day).count > 0
			availability_by_dts(Time.now + 2.day).first

		elsif availability_by_dts(Time.now + 3.day).count > 0
			availability_by_dts(Time.now + 3.day).first

		elsif availability_by_dts(Time.now + 4.day).count > 0
			availability_by_dts(Time.now + 4.day).first

		elsif availability_by_dts(Time.now + 5.day).count > 0
			availability_by_dts(Time.now + 5.day).first

		elsif availability_by_dts(Time.now + 6.day).count > 0
			availability_by_dts(Time.now + 6.day).first

		elsif availability_by_dts(Time.now + 7.day).count > 0
			availability_by_dts(Time.now + 7.day).first
		end
	end

	def available_on_day(wday)
		if wday == 0
			available_sunday
		elsif wday == 1
			available_monday
		elsif wday == 2
			available_tuesday
		elsif wday == 3
			available_wednesday
		elsif wday == 4
			available_thursday
		elsif wday == 5
			available_friday
		elsif wday == 6
			available_saturday
    end
	end

	def self.active_counselors
		self.where(:is_active => true)
		
	end

	def upcoming_sessions
    counseling_sessions.where(:cancelled_on_dts => nil).where("start_datetime >= ?", Time.zone.now)
  end

  def previous_sessions
    counseling_sessions.where("start_datetime <= ?", Time.zone.now)
  end

	private

	def parse_dts(string)
    DateTime.parse(string)
  end

	def _create_stripe_recipient_id
		unless user.stripe_recipient_id.present?
	  	recipient = Stripe::Recipient.create(
	  		:name  			 => "#{user.name}",
			  :email 			 => "#{user.email}",
			  :description => "MoodCall Counselor",
			 	:type 			 => "individual"
			)

			user.stripe_recipient_id = recipient.id
		end
	end
end
