json.array!(@counselors) do |counselor|
  json.extract! counselor, :id, :bio, :photo, :profession_start_date, :slug, :user_id, :hourly_rate_in_cents, :hourly_fee_in_cents, :send_session_sms_alerts, :send_session_email_alerts, :advanced_scheduling_in_weeks, :available_monday, :available_tuesday, :available_wednesday, :available_thursday, :available_friday, :available_saturday, :available_sunday
  json.url counselor_url(counselor, format: :json)
end
