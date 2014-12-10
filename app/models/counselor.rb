class Counselor < ActiveRecord::Base
	belongs_to :user
	before_create :_generate_default_information

	private

	def _generate_default_information
		self.bio = "I'm passionate about help people reach their full potential. I look forward to leveraging my professional experience to help you reach your full potential."
		self.profession_start_date = Time.now
	end
end
