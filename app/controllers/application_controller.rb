class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_timezone
  before_action :set_dts
  before_action :save_location

  def save_location
    # save last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? 
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        request.path != "/" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    end
  end

  def after_sign_in_path_for(resource)
    session[:profileViews] = Array.new
    unless session[:pending_session_counselor_id].present?
      if session[:previous_url]
        session[:previous_url]
      elsif current_user.counselor.present?
        user_dashboard_path(:q => :counselor)
      else
        user_dashboard_path
      end
    else
      new_counseling_session_path
    end
  end

  def after_confirmation_path_for(resource_name, resource)
    if current_user.counselor.present?
      user_dashboard_path(:q => :counselor)
    else
      user_dashboard_path
    end
  end

  def set_timezone
  	Time.zone = cookies[:moodcall_timezone] || "Eastern Time (US & Canada)"
  end

  def set_dts
    @dts = params[:datetime] ? Date.strptime("#{params[:datetime]}", "%m/%d/%Y") : Time.zone.today
  end

end
