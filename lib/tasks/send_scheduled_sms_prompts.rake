desc "Send Scheduled SMS Prompts"
task :send_scheduled_sms_prompts => :environment do

  # Handle SMS Prompts
  @smsable_prompts = SessionPrompt.select do |pre|
    pre.scheduled_send_dts             < Time.now and
    pre.sent_sms_dts                   == nil and
    pre.prompt.enable_sms              == true and
    pre.user.send_session_sms_alerts   == true
  end

  @client = Twilio::REST::Client.new

  @smsable_prompts.each do |pre|
    puts "Texting Prompt"
    if @client.messages.create(
        from: '+16789741147',
        to: '+14043942015',
        body: "#{pre.prompt.sms_message}"
      )
      pre.sent_sms_dts = Time.now
      pre.save
    end
  end
end
