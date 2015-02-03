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
end
