class SessionPrompt < ActiveRecord::Base
  belongs_to :user
  belongs_to :counseling_session
  belongs_to :prompt

  validates_uniqueness_of :prompt, :scope => :counseling_session

  def self.sendable_prompts
    self.select do |pre|
      pre.scheduled_send_dts             < Time.now and
      pre.sent_dts                       == nil and
      pre.user.send_session_email_alerts == true
    end
  end

  def self.sendable_email_prompts
    self.select do |pre|
      pre.scheduled_send_dts             < Time.now and
      pre.sent_email_dts                 == nil and
      pre.prompt.enable_email            == true and
      pre.user.send_session_email_alerts == true
    end
  end

  def self.sendable_sms_prompts
    self.select do |pre|
      pre.scheduled_send_dts             < Time.now and
      pre.sent_sms_dts                   == nil and
      pre.prompt.enable_sms              == true and
      pre.user.send_session_sms_alerts   == true and
      pre.user.phone.present?
    end
  end
end
