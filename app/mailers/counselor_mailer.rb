class CounselorMailer < ActionMailer::Base
  default from: "info@moodycall.org"

  def client_cancellation(counseling_session_id)
    @counseling_session = CounselingSession.find(counseling_session_id)
    @client             = @counseling_session.client
    @counselor          = @counseling_session.counselor.user
    @greeting           = "Hello"

    mail to: "#{@counselor.email}",
    subject: "Counseling Session Cancellation"
  end

  def new_counseling_session(counseling_session_id)
    @counseling_session = CounselingSession.find(counseling_session_id)
    @client             = @counseling_session.client
    @counselor          = @counseling_session.counselor.user
    @greeting           = "Hello"

    mail to: "#{@counselor.email}",
    subject: "Congratulations! You've Been Scheduled with MoodyCall!"
  end

  def availability_expired_notice(user)
    @user = user
    @userName = @user.first_name

    mail to: "#{@user.email}",
    subject: "Your availability at MoodyCall is about to run out!"
  end
end
