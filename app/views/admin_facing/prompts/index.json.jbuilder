json.array!(@prompts) do |prompt|
  json.extract! prompt, :id, :duration, :interval, :send_before_session, :enable_sms, :sms_message, :enable_email, :email_message, :audience_type, :is_active
  json.url prompt_url(prompt, format: :json)
end
