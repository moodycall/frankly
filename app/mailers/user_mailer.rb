class UserMailer < ActionMailer::Base
  default from: "info@moodycall.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.prompt_message.subject
  #
  def prompt_message(pre)
    @greeting = "Hi"
    @pre      = pre
    @prompt   = pre.prompt

    mail to: "#{@pre.user.email}",
    subject: "#{@prompt.name}"
  end

  def provide_cc_info(user_id)
    @greeting = "Hello"
    @user     = User.find(user_id)
    @general  = General.where(:item => "provide credit card info").last()
    subject   = @general[:subject]
    content   = @general[:content]
    
    content.gsub!("http://mclink",new_credit_card_url)

    mail to: "#{@user.email}",
    subject: "#{subject}",
    content_type: "text/html",
    body: "#{content}"
  end

  def counseling_session_charge_confirmation(counseling_session_id)
    @counseling_session = CounselingSession.find(counseling_session_id)
    @client             = @counseling_session.client
    @general  = General.where(:item => "charged for session").last()
    subject   = @general[:subject]
    content   = @general[:content]

    content.gsub!("mcClientName",@client.name)
    content.gsub!("mcCounselorName",@counseling_session.counselor.user.name)
    content.gsub!("mcSessionDate",@counseling_session.start_datetime.strftime("%B %e, %Y at %l:%M%P %Z"))

    mail to: "#{@client.email}",
    subject: "#{subject}",
    content_type: "text/html",
    body: "#{content}"
  end

  def counseling_session_cancellation(counseling_session_id)
    @counseling_session = CounselingSession.find(counseling_session_id)
    @client             = @counseling_session.client
    @counselor          = @counseling_session.counselor.user
    @general  = General.where(:item => "Counseling Session Cancellation (by counselor)").last()
    subject   = @general[:subject]
    content   = @general[:content]
    
    content.gsub!("mcClientName",@client.name)
    content.gsub!("mcCounselorName",@counselor.name)
    content.gsub!("mcSessionDate",@counseling_session.start_datetime.strftime("%B %e, %Y at %l:%M%P %Z"))

    mail to: "#{@client.email}",
    subject: "#{subject}",
    content_type: "text/html",
    body: "#{content}"
  end
end
