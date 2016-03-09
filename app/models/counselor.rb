class Counselor < ActiveRecord::Base
	include ActionView::Helpers

	extend FriendlyId
  friendly_id :created_slug, use: [:slugged, :history, :finders]

	belongs_to :user

	has_many :availability_intervals
	has_many :availability_dates
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
	validates :phone,   
							:presence => true,
							:numericality => true,
							:length => { :minimum => 10, :maximum => 15 }
												
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

	def all_available(date,type)
		daysArr 	= []
		daysArr[0] 	= 'Sunday'
		daysArr[1] 	= 'Monday'
		daysArr[2] 	= 'Tuesday'
		daysArr[3] 	= 'Wednesday'
		daysArr[4] 	= 'Thursday'
		daysArr[5] 	= 'Friday'
		daysArr[6] 	= 'Saturday'

		resultArr 	= []
		
		if availability_dates.present?
			timezone_name 	= availability_dates.joins(:availability_intervals).first.availability_intervals.first.timezone_name
			searchDate		= Time.now.in_time_zone(timezone_name)
			currentTime 	= Time.now.in_time_zone(timezone_name)
			pre_timezone 	= Time.zone
			searchQuery 	= "availability_dates.end_date >= '#{searchDate}'"

			allDates 		= availability_dates.joins(:availability_intervals).where(searchQuery).distinct("availability_dates.id")
			
			allDates.each do |d|
				
				preDate 	= 0
				availableExist 	= false
				
				d.availability_intervals.each do |t|

					Time.zone 	= timezone_name
					start_time 	= DateTime.parse(t.start_time)
					end_time	= DateTime.parse(t.end_time) - 30.minutes

					weekDay		= daysArr[t.day_of_week]
					nextDate 	= date_of_next "#{weekDay}",t.timezone_name

					while d.end_date >= nextDate and
						 (preDate == 0 or nextDate <= preDate or type == 'unique' or type == 'specific') and
						 (type != 'specific' or type != 'unique' or
						 (nextDate.in_time_zone(pre_timezone) <= date.end_of_day))

						availableTime 	= (Time.zone.local(nextDate.year, nextDate.month, nextDate.day, start_time.hour, start_time.min, start_time.sec))
						availableEnds 	= (Time.zone.local(nextDate.year, nextDate.month, nextDate.day, end_time.hour, end_time.min, end_time.sec))
						availableExist	= false

						if d.start_date <= nextDate and nextDate.end_of_day.in_time_zone(pre_timezone) >= date.beginning_of_day
							
							(0..47).each do |step|

								timeInUserZone 	= availableTime.in_time_zone(pre_timezone)
								
								if (availableTime <= availableEnds and
									 availableTime > currentTime + 30.minutes) and
									 ((type == 'next') or ((type == 'all' or type == 'unique') and timeInUserZone>=date.beginning_of_day) or (type == 'specific' and timeInUserZone.between?(date.beginning_of_day,date.end_of_day)))
									
									if !booked_on(availableTime).present?
										availableExist = true
										resultArr.push(availableTime)
									end
								end
								availableTime += 30.minutes
							end
						end
						
						if availableExist and type != 'specific' and type != 'unique'
							preDate	= nextDate
							break
						end
						nextDate += 7.days
					end
				end
				Time.zone = pre_timezone
			end
		end
		resultArr.sort_by!{|e| e}
	end
	
	def availability_by_dts(date)
		
		timeArr 	= []
		resultArr 	= []
		resultArr 	= all_available(date,'specific')
	end

	def next_available
		
		resultArr = all_available(Time.now.in_time_zone,'next')
		
		if resultArr.count
			resultArr.first
		end
	end

	def available_after(date)
		resultArr = all_available(date,'all')
		
		if resultArr.count
			resultArr.first
		end
	end

	def booked_on(time)

		time 	= time.utc
		ntime 	= time-30.minutes
		
		query = "((start_datetime = '#{time}') or (start_datetime = '#{ntime}' and estimate_duration_in_minutes = 60))"
		counseling_sessions.where("#{query}",:cancelled_on_dts => nil).all
	end

	def date_of_next(day,timezone_name)
  		date  = Date.parse(day).in_time_zone(timezone_name)
		delta = date >= Time.zone.today ? 0 : 7
		(Date.parse(day) + delta).in_time_zone(timezone_name)
	end

	def unique_available_days()
		dateArray = []
		items = all_available(Time.now.in_time_zone,'unique')
		items.each do |t|
			dt = t.in_time_zone.strftime("%d-%m-%Y")
			if !dateArray.include? dt
				dateArray.push(dt)
			end
		end
  		dateArray
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
