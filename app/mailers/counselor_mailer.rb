class CounselorMailer < ActionMailer::Base
  default from: "info@moodycall.org"

  def client_cancellation(counseling_session_id)
    @counseling_session = CounselingSession.find(counseling_session_id)
    @client             = @counseling_session.client
    @counselor          = @counseling_session.counselor.user
    @greeting           = "Hello"

    mail to: "#{@counselor.email}",
    subject: "Client Cancellation via MoodyCall"
  end

  def new_counseling_session(counseling_session_id)
    @counseling_session = CounselingSession.find(counseling_session_id)
    @client             = @counseling_session.client
    @counselor          = @counseling_session.counselor.user
    @greeting           = "Hello"

    mail to: "#{@counselor.email}",
    subject: "Congratulations! You've Been Scheduled with MoodyCall!"
  end
end
