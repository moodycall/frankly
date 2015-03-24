class Specialty < ActiveRecord::Base
	extend FriendlyId
  friendly_id :name, use: [:slugged, :history, :finders]

	has_many :specializations
	has_many :counselors, :through => :specializations

  def self.staffed_specialties
    self.where(:is_active => true).select do |specialty|
      specialty.counselors.count > 0
    end
  end
end
