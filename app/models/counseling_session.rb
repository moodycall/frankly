class CounselingSession < ActiveRecord::Base
	extend FriendlyId
  friendly_id :secure_id, use: [:slugged, :history, :finders]

  has_one :rating

	belongs_to :counselor
	belongs_to :client, :class_name => "User"

	attr_accessor :time, :day

	before_create :_generate_secure_id
	before_create :_set_default_values

	def price_in_dollars
		price_in_cents / 100
	end

	def estimated_endtime
		start_datetime + estimate_duration_in_minutes.minutes
	end

	private

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
