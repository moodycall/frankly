class Prompt < ActiveRecord::Base
  extend FriendlyId
  friendly_id :secure_id, use: [:slugged, :history, :finders]

  has_many :session_prompts
  has_many :user, through: :session_prompts
  has_many :session, through: :session_prompts

  INTERVAL_MINUTES = 1
  INTERVAL_HOURS   = 2
  INTERVAL_DAYS    = 3
  INTERVAL_MONTHS  = 4

  AUDIENCE_CLIENT    = 1
  AUDIENCE_COUNSELOR = 2

  before_create :_generate_secure_id

  def self.interval_options
    {
      INTERVAL_MINUTES => "minutes",
      INTERVAL_HOURS   => "hours",
      INTERVAL_DAYS    => "days",
      INTERVAL_MONTHS  => "months"
    }
  end

  def self.audience_types
    {
      AUDIENCE_CLIENT      => "client",
      AUDIENCE_COUNSELOR   => "counselor"
    }
  end

  def interval_as_string
    case interval
      when Prompt::INTERVAL_MINUTES
        'minutes'
      when Prompt::INTERVAL_HOURS
        'hours'
      when Prompt::INTERVAL_DAYS
        'days'
      when Prompt::INTERVAL_MONTHS
        'months'
    end
  end

  def audience_as_string
    case audience_type
      when Prompt::AUDIENCE_CLIENT
        'client'
      when Prompt::AUDIENCE_COUNSELOR
        'counselor'
    end
  end

  def proximity_to_session
    if send_before_session == true
      "before"
    else
      "after"
    end
  end

  private

  def _generate_secure_id
    unless self.secure_id.present?
      self.secure_id = "#{SecureRandom.hex(2).upcase}"
      self.slug      = self.secure_id
    end
  end
end
