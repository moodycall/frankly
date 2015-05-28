desc "Send Scheduled Email Prompts"
task :send_scheduled_email_prompts => :environment do

  # Handle Email Prompts
  puts "Collecting Sendable Email Prompts"
  @emailable_prompts = SessionPrompt.sendable_email_prompts

  @emailable_prompts.each do |pre|
    puts "Emailing Prompt"
    if UserMailer.prompt_message(pre).deliver
      pre.sent_email_dts = Time.now
      pre.save
    end
  end
end
