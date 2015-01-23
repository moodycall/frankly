class SessionPrompt < ActiveRecord::Base
  belongs_to :user
  belongs_to :session
  belongs_to :prompt

  validates_uniqueness_of :prompt, :scope => :session
end
