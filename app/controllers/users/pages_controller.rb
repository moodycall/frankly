class Users::PagesController < ApplicationController
  before_filter :authenticate_user!

  def dashboard
    @upcoming_sessions = current_user.upcoming_sessions.order("start_datetime asc")
    @previous_sessions = current_user.previous_sessions.order("start_datetime desc").last(5)
  end

  def session_history
    @counseling_sessions = current_user.counseling_sessions.all
  end
end