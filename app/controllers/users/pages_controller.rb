class Users::PagesController < ApplicationController
  before_filter :authenticate_user!

  def dashboard
    if params[:q] == "counselor"
      @upcoming_sessions = current_user.counselor.upcoming_sessions.order("start_datetime asc")
      @previous_sessions = current_user.counselor.previous_sessions.order("start_datetime desc").first(5)
    else
      @upcoming_sessions = current_user.upcoming_sessions.order("start_datetime asc")
      @previous_sessions = current_user.previous_sessions.order("start_datetime desc").first(5)
    end
  end

  def session_history
    if params[:q] == "counselor"
      @counseling_sessions = current_user.counselor.counseling_sessions.all
    else
      @counseling_sessions = current_user.counseling_sessions.all
    end
  end
end