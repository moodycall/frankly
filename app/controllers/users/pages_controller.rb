class Users::PagesController < ApplicationController
  before_filter :authenticate_user!

  def dashboard
    
  end

  def session_history
    @counseling_sessions = current_user.counseling_sessions.all
  end
end