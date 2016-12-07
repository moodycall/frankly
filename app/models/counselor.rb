class Counselor < ActiveRecord::Base
	include ActionView::Helpers

	extend FriendlyId
  friendly_id :created_slug, use: [:slugged, :history, :finders]

	belongs_to :user

	has_many :availability_intervals
	has_many :availability_dates
	has_many :availability_days
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
							:profession_start_date
							:photo
	validates :phone,   
							:presence => true,
							:numericality => true,
							:length => { :minimum => 10, :maximum => 15 }
												
	# before_create :_create_stripe_recipient_id

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
			session.stripe_charge_id != nil and
			session.payout_id.nil?
		end
	end

	def single_payable_sessions
		counseling_sessions.select do |session|
			session.estimated_endtime < Time.now and
			session.refund_amount_in_cents == nil and
			session.stripe_charge_id != nil and
			session.payout_id.nil? and
			session.estimate_duration_in_minutes == 30
		end
	end

	def double_payable_sessions
		counseling_sessions.select do |session|
			session.estimated_endtime < Time.now and
			session.refund_amount_in_cents == nil and
			session.stripe_charge_id != nil and
			session.payout_id.nil? and
			session.estimate_duration_in_minutes == 60
		end
	end

	def total_payable_sessions_count
		single_payable_sessions.count + (double_payable_sessions.count * 2)
	end

	def payable_total_in_dollars
		total_payable_sessions_count * session_net_profit_in_dollars
	end

	def payable_total_in_cents
		(total_payable_sessions_count * session_net_profit_in_dollars) * 100
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

	def counseling_sessions_count
		counseling_sessions.count
	end

	def payable_sessions_count
		payable_sessions.count
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
		hourly_rate_in_cents / 60.0
	end

	def years_in_business
		distance_of_time_in_words(profession_start_date, Time.now)
	end

	def booked_session_by_date(date)
    	booked_sessions = counseling_sessions.where(:cancelled_on_dts => nil, start_datetime: Date.parse(date.to_s).beginning_of_day..Date.parse(date.to_s).end_of_day).all
  	end
	
	def availabilitytime
		self.availability_days.first.available_datetime
	end

	def availability_by_dts(date)
		currentTimeUtc 	= (Time.now.utc + 30.minutes).strftime("%Y-%m-%d %H:%M:%S")
		searchStartDate	= date.beginning_of_day.utc.strftime("%Y-%m-%d %H:%M:%S")
		searchEndDate	= date.end_of_day.utc.strftime("%Y-%m-%d %H:%M:%S")
		where 			= "active=true and available_datetime>='#{searchStartDate}' and available_datetime<='#{searchEndDate}' and available_datetime>'#{currentTimeUtc}'"
		availableOnDate	= availability_days.select("available_datetime as time").where("#{where}").order("available_datetime")
		availableOnDate
		
	end

	def next_available		
		currentTimeUtc 	= (Time.now.utc + 30.minutes).strftime("%Y-%m-%d %H:%M:%S")
		nextAvailable 	= availability_days.select("available_datetime as time").where("active=true and available_datetime>'#{currentTimeUtc}'").order("available_datetime").first
		if nextAvailable
			nextAvailable.time
		else
			false
		end
				
	end

	def unique_available_days()
		
		currentTime 	= (Time.now.utc + 30.minutes).strftime("%Y-%m-%d %H:%M:%S")
		where       	= "active=true and available_datetime > '#{currentTime}'"
  		available_days 	= availability_days.select("start_datetime").where("#{where}").order("start_datetime").distinct('start_datetime')
	
		dateArray 		= []
		available_days.each do |available_day|
			dateArray.push(available_day[:start_datetime].strftime("%d-%m-%Y"))
		end
		dateArray
	end

	def is_available_at(time)
		where       = "active=true and available_datetime = '#{time}'"
  		available 	= availability_days.count "#{where}"
  		# if available > 0
		true
		# else
		# false
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

	def _create_stripe_recipient_id
		unless user.stripe_recipient_id.present?
		  	recipient = Stripe::Account.create(
				:managed => true,
        		:country => 'US',
				:email => "#{user.email}"
			)

			user.stripe_recipient_id = recipient.id
		end
	end

	private

	def parse_dts(string)
    	DateTime.parse(string)
  	end
end
