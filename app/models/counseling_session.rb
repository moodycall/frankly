class CounselingSession < ActiveRecord::Base
	require "opentok"

	extend FriendlyId
  friendly_id :secure_id, use: [:slugged, :history, :finders]

  has_one :rating

  has_many :session_prompts
  has_many :prompts, through: :session_prompts

	belongs_to :counselor
	belongs_to :payout
	belongs_to :client, :class_name => "User"

	attr_accessor :time, :day

	before_create :_generate_secure_id
	before_create :_set_default_values
	after_save :_create_before_prompts_for_client

	def create_opentok_session
		api_key    = Rails.configuration.opentok_api_key
    api_secret = Rails.configuration.opentok_api_secret

    opentok    = OpenTok::OpenTok.new api_key, api_secret 
    session    = opentok.create_session :media_mode => :routed
    session_id = session.session_id

    self.opentok_session_id = session_id
    self.save
	end

	def price_in_dollars
		price_in_cents / 100
	end

	def estimated_endtime
		start_datetime + estimate_duration_in_minutes.minutes
	end

	private

	def _create_before_prompts_for_client
		@client_before_prompts = Prompt.where(:audience_type => 1, :is_active => true, :send_before_session => true).all

		@client_before_prompts.each do |prompt|

			preprompt        						 = self.session_prompts.new
    	preprompt.prompt             = prompt
    	preprompt.user               = self.client

	    if prompt.interval == 1    # Minutes
	    	send_time = self.start_datetime - (prompt.quantity).minutes
	    elsif prompt.interval == 2 # Hours
	    	send_time = self.start_datetime - (prompt.quantity).hours
	    elsif prompt.interval == 3 # Days
	    	send_time = self.start_datetime - (prompt.quantity).days
	    elsif prompt.interval == 4 # Months
	    	send_time = self.start_datetime - (prompt.quantity).months
	    end

	    if send_time > Time.now
	    	preprompt.scheduled_send_dts = send_time
				preprompt.save
			end
	  end
	end

	def _create_before_prompts_for_client
		@client_before_prompts = Prompt.where(:audience_type => 2, :is_active => true, :send_before_session => true).all

		@client_before_prompts.each do |prompt|

			preprompt        						 = self.session_prompts.new
    	preprompt.prompt             = prompt
    	preprompt.user               = self.client

	    if prompt.interval == 1    # Minutes
	    	send_time = self.start_datetime - (prompt.quantity).minutes
	    elsif prompt.interval == 2 # Hours
	    	send_time = self.start_datetime - (prompt.quantity).hours
	    elsif prompt.interval == 3 # Days
	    	send_time = self.start_datetime - (prompt.quantity).days
	    elsif prompt.interval == 4 # Months
	    	send_time = self.start_datetime - (prompt.quantity).months
	    end

	    if send_time > Time.now
	    	preprompt.scheduled_send_dts = send_time
				preprompt.save
			end
	  end
	end

	def _set_default_values
		unless self.estimate_duration_in_minutes.present?
			self.estimate_duration_in_minutes = 30
		end
		self.price_in_cents									= counselor.minutely_rate_in_cents * self.estimate_duration_in_minutes
	end

	def _generate_secure_id
		unless self.secure_id.present?
			self.secure_id = "#{Time.now.strftime('%y%m%d')}#{SecureRandom.hex(2).upcase}"
			self.slug 		 = self.secure_id
		end
	end
end
