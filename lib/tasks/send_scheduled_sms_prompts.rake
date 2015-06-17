desc "Send Scheduled SMS Prompts"
task :send_scheduled_sms_prompts => :environment do

  # Handle SMS Prompts
  puts "Collecting Sendable SMS Prompts"
  @smsable_prompts = SessionPrompt.sendable_sms_prompts

  @client = Twilio::REST::Client.new

  @smsable_prompts.each do |pre|
    puts "Texting Prompt"
    if @client.messages.create(
        from: '+16789169655',
        to:   '+1#{pre.user.phone}',
        body: "#{pre.prompt.sms_message}"
      )
      pre.sent_sms_dts = Time.now
      pre.save
    end
  end
end
