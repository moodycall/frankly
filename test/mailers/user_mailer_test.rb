require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "prompt_message" do
    mail = UserMailer.prompt_message
    assert_equal "Prompt message", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
