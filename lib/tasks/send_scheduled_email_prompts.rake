desc "Send Scheduled Email Prompts"
task :send_scheduled_email_prompts => :environment do

  # Handle Email Prompts
  @emailable_prompts = SessionPrompt.select do |pre|
    pre.scheduled_send_dts             < Time.now and
    pre.sent_email_dts                       == nil and
    pre.prompt.enable_email            == true and
    pre.user.send_session_email_alerts == true
  end

  @emailable_prompts.each do |pre|
    puts "Emailing Prompt"
    if UserMailer.prompt_message(pre).deliver
      pre.sent_email_dts = Time.now
      pre.save
    end
  end
end
