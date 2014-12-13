class Counselor < ActiveRecord::Base
	include ActionView::Helpers

	extend FriendlyId
  friendly_id :created_slug, use: [:slugged, :history, :finders]

	belongs_to :user

	has_many :availability_intervals

	accepts_nested_attributes_for :availability_intervals
	
	before_create :_generate_default_information
	before_create :_create_stripe_recipient_id

	def created_slug
		self.user.name
	end

	def hourly_rate_in_dollars
		hourly_rate_in_cents * 0.01
	end

	def years_in_business
		distance_of_time_in_words(profession_start_date, Time.now)
	end

	private

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
			user.save
		end
	end
end
