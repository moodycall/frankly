class CounselingSession < ActiveRecord::Base
	belongs_to :counselor
	belongs_to :user, :foreign_key => 'client_id'

	attr_accessor :time, :day
end
