class CounselorMailer < ActionMailer::Base
  default from: "team@moodycall.org"

  def client_cancellation(counseling_session_id)
    @counseling_session = CounselingSession.find(counseling_session_id)
    @client             = @counseling_session.client
    @counselor          = @counseling_session.counselor.user
    @greeting           = "Hello"

    mail to: "#{@counselor.email}",
    subject: "Client Cancellation via MoodyCall"
  end
end
