class Counselor < ActiveRecord::Base
	include ActionView::Helpers
	belongs_to :user
	before_create :_generate_default_information

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
end
