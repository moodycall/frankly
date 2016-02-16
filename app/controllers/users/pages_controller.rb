class Users::PagesController < ApplicationController
  before_filter :authenticate_user!

  def dashboard
    if params[:q] == "counselor" and current_user.counselor
      @upcoming_sessions = current_user.counselor.upcoming_sessions
      @previous_sessions = current_user.counselor.previous_sessions.first(5)
      @page_title = "Dashboard"
      @page_subtitle = "Counselor dashboard"
    elsif !current_user.is_counselor? or current_user.counselor
      @upcoming_sessions = current_user.upcoming_sessions
      @previous_sessions = current_user.previous_sessions.first(5)
      @page_title = "Dashboard"
      @page_subtitle = "User dashboard"
    else
      redirect_to new_counselor_path
    end

  end

  def session_history
    if params[:q] == "counselor" and current_user.counselor
      @counseling_sessions = current_user.counselor.previous_sessions
    else
      @counseling_sessions = current_user.previous_sessions
    end
  end
end