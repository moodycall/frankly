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
end
