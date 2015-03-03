class UserMailer < ActionMailer::Base
  default from: "team@moodycall.org"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.prompt_message.subject
  #
  def prompt_message(pre)
    @greeting = "Hi"
    @pre      = pre
    @prompt   = pre.prompt

    mail to: "#{@pre.user.email}"
  end

  def provide_cc_info(user_id)
    @greeting = "Hello"
    @user     = User.find(user_id)

    mail to: "#{@user.email}",
    subject: "Please Add a Credit Card"
  end

  def counseling_session_charge_confirmation(counseling_session_id)
    @counseling_session = CounselingSession.find(counseling_session_id)
    @client             = @counseling_session.client
    @greeting           = "Hello"

    mail to: "#{@client.email}",
    subject: "Charged for Counseling Session via MoodyCall"
  end
end
