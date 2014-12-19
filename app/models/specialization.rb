class Specialization < ActiveRecord::Base
	belongs_to :counselor
	belongs_to :specialty
end
