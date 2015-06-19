class Users::PagesController < ApplicationController
  before_filter :authenticate_user!

  def dashboard
    if params[:q] == "counselor" and current_user.counselor
      @upcoming_sessions = current_user.counselor.upcoming_sessions
      @previous_sessions = current_user.counselor.previous_sessions.first(5)
    else
      @upcoming_sessions = current_user.upcoming_sessions
      @previous_sessions = current_user.previous_sessions.first(5)
    end
  end

  def session_history
    if params[:q] == "counselor" and current_user.counselor
      @counseling_sessions = current_user.counselor.counseling_sessions.previous_sessions
    else
      @counseling_sessions = current_user.counseling_sessions.previous_sessions
    end
  end
end