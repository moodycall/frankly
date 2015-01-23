require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

# put your own credentials here
account_sid = Rails.configuration.twilio_account_sid
auth_token = Rails.configuration.twilio_auth_token

Twilio.configure do |config|
  config.account_sid = account_sid
  config.auth_token = auth_token
end
