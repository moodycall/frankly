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

	def is_user_favorite(user_id)
		user = User.find(user_id)
		if user.favorite_counselors.where(:counselor_id => self.id).present?
			return true
		else
			return false
		end
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

	def minutely_rate_in_cents
		hourly_rate_in_cents / 60
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
		end
	end
end
