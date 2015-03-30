class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_timezone
  before_action :set_dts
  after_filter :save_location

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
    unless session[:pending_session_counselor_id].present?
      session[:previous_url] || "/dashboard"
    else
      new_counseling_session_path
    end
  end

  def set_timezone
  	Time.zone = cookies[:moodcall_timezone] || "Eastern Time (US & Canada)"
  end

  def set_dts
    @dts = params[:datetime] ? Date.parse(params[:datetime]) : Time.zone.now
  end

  private

  def authenticate_user!
    if user_signed_in?
      super
    else
      redirect_to new_user_registration_path, :notice => 'Please signup or login before you continue.'
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end
end
