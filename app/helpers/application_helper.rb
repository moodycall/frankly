module ApplicationHelper
	def time_as_utc(time)
		Time.strptime(time, "%l:%M%P").strftime("%I:%M%P")
	end

  def time_as_local(time)
    DateTime.parse(time).in_time_zone.strftime("%I:%M%P")
  end

  def parse_dts(string)
    DateTime.parse(string)
  end
end
