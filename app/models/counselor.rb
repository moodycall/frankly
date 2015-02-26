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

	accepts_nested_attributes_for :availability_intervals
	
	before_create :_generate_default_information
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

	def availability_by_dts(datetime)
		available_times = []
		daily_times = ["12:00am","12:30am","01:00am","01:30am","02:00am","02:30am","03:00am","03:30am","04:00am","04:30am","05:00am","05:30am","06:00am","06:30am","07:00am","07:30am","08:00am","08:30am","09:00am","09:30am","10:00am","10:30am","11:00am","11:30am","12:00pm","12:30pm","01:00pm","01:30pm","02:00pm","02:30pm","03:00pm","03:30pm","04:00pm","04:30pm","05:00pm","05:30pm","06:00pm","06:30pm","07:00pm","07:30pm","08:00pm","08:30pm","09:00pm","09:30pm","10:00pm","10:30pm","11:00pm","11:30pm"]
		
		if available_on_day(datetime.wday)
			availability_intervals.where(:day_of_week => datetime.wday).each do |interval|
				daily_times.each do |time|
					# Time is currently excluding entire day
					# dts = datetime.change(:hour => parse_dts(time).strftime("%k").to_i, :min => parse_dts(time).strftime("%M").to_i)
					if parse_dts(time).between?(parse_dts(interval.start_time), (parse_dts(interval.end_time) - 30.minutes))
						if (datetime).in_time_zone > 1.day.ago
							available_times.push(time)
						end
					end
				end
			end
		end

		available_times
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

	private

	def parse_dts(string)
    DateTime.parse(string)
  end

	def _generate_default_information
		self.bio = "I'm passionate about help people reach their full potential. I look forward to leveraging my professional experience to help you reach your full potential."
		self.profession_start_date = Time.now
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
