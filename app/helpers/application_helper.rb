module ApplicationHelper
	def time_as_utc(time)
		Time.strptime(time, "%l:%M%P").strftime("%H:%M")
	end
end
