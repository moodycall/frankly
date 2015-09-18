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

	def session_count_with_client(client_id)
    counseling_sessions.where(:client_id => client_id).count
  end

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
		hourly_rate_in_dollars / 2.0
	end

	def session_fee_in_dollars
		hourly_fee_in_dollars / 2.0
	end

	def minutely_rate_in_cents
		hourly_rate_in_cents / 60.0
	end

	def years_in_business
		distance_of_time_in_words(profession_start_date, Time.now)
	end

	def booked_session_by_date(date)
    booked_sessions = counseling_sessions.where(:cancelled_on_dts => nil, start_datetime: Date.parse(date.to_s).beginning_of_day..Date.parse(date.to_s).end_of_day).all
  end

	def availability_by_dts(date)
		# DateTime.new(date.year, date.month, date.day, interval_start.hour, interval_start.min, interval_start.sec, interval_start.zone)
		weeks_until_date =  (date.end_of_day - Time.now).to_i / 604800

		if weeks_until_date <= advanced_scheduling_in_weeks 
			all_times = availability_intervals.all_availabilities(date)

	  	booked_session_by_date(date).each do |booked_session|
				if booked_session.estimate_duration_in_minutes == 60
					time_to_remove = [Time.zone.parse("#{booked_session.start_datetime}").utc, Time.zone.parse("#{booked_session.start_datetime + 30.minutes}").utc]
				else
					time_to_remove = [Time.zone.parse("#{booked_session.start_datetime}").utc]
				end

				all_times = all_times.reject{ |e| time_to_remove.include? e }
	    end

			all_times.sort_by{|e| e}
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
		counseling_sessions.where(:cancelled_on_dts => nil).order("start_datetime asc").select do |session|
      session.estimated_endtime > Time.zone.now
    end
  end

  def previous_sessions
  	counseling_sessions.where(:cancelled_on_dts => nil).order("start_datetime desc").select do |session|
      session.estimated_endtime < Time.now
    end
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
