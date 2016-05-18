class CounselorMailer < ActionMailer::Base
  default from: "info@moodycall.org"

  def client_cancellation(counseling_session_id)
    @counseling_session = CounselingSession.find(counseling_session_id)
    @client             = @counseling_session.client
    @counselor          = @counseling_session.counselor.user
    @general            = General.where(:item => "Counseling Session Cancellation (by client)").last()
    subject             = @general[:subject]
    content             = @general[:content]

    content.gsub!("mcClientName",@client.name)
    content.gsub!("mcCounselorName",@counselor.name)
    content.gsub!("mcSessionDate",@counseling_session.start_datetime.strftime("%B %e, %Y at %l:%M%P %Z"))

    mail to: "#{@counselor.email}",
    subject: "#{subject}",
    content_type: "text/html",
    body: "#{content}"
  end

  def new_counseling_session(counseling_session_id)
    @counseling_session = CounselingSession.find(counseling_session_id)
    @client             = @counseling_session.client
    @counselor          = @counseling_session.counselor.user
    @general            = General.where(:item => "New Counseling Session").last()
    subject             = @general[:subject]
    content             = @general[:content]

    content.gsub!("mcClientName",@client.name)
    content.gsub!("mcCounselorName",@counselor.name)
    content.gsub!("mcSessionDate",@counseling_session.start_datetime.strftime("%B %e, %Y at %l:%M%P %Z"))

    mail to: "#{@counselor.email}",
    subject: "#{subject}",
    content_type: "text/html",
    body: "#{content}"
  end

  def availability_expired_notice(user)
    @user = user
    @userName = @user.first_name
    @general = General.where(:item => "availability expiration in 5 days").last()
    subject = @general[:subject]
    content = @general[:content]
    content.gsub!("mcCounselorName",@userName)

    mail to: "#{@user.email}",
    subject: "#{subject}",
    content_type: "text/html",
    body: "#{content}"
  end

  def availability_expire_in_one_day(user)
    @user = user
    @userName = @user.first_name
    @general = General.where(:item => "availability expiration in 1 day").last()
    subject = @general[:subject]
    content = @general[:content]
    content.gsub!("mcCounselorName",@userName)

    mail to: "#{@user.email}",
    subject: "#{subject}",
    content_type: "text/html",
    body: "#{content}"
  end

  def availability_admin_notif(user)
    @user = user
    @userName = @user.first_name
    @general = General.where(:item => "availability expiration admin notification").last()
    subject = @general[:subject]
    content = @general[:content]
    content.gsub!("mcCounselorName",@userName)

    mail to: "info@moodycall.org",
    subject: "#{subject}",
    content_type: "text/html",
    body: "#{content}"
  end

  def counselor_deleted(name, email)
    @general = General.where(:item => "counselor deleted by admin").last()
    subject = @general[:subject]
    content = @general[:content]
    content.gsub!("mcCounselorName",name)

    mail to: "#{email}",
    subject: "#{subject}",
    content_type: "text/html",
    body: "#{content}"
  end

end
