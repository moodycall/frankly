module ApplicationHelper
	def time_as_utc(time)
		Time.strptime(time, "%l:%M%P").strftime("%I:%M%P")
	end

  def time_as_local(time)
    time.in_time_zone.strftime("%I:%M%P")
  end

  def parse_dts(string)
    DateTime.parse(string)
  end

  def cents_to_dollars(total_in_cents)
    if total_in_cents
      number_to_currency(total_in_cents * 0.01)
    end
  end

  def generated_dts(date, time)
    t = parse_dts(time)
    dt = DateTime.new(date.year, date.month, date.day, t.hour, t.min, t.sec, t.zone)
  end
end
