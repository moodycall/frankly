class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_timezone
  before_action :set_dts

  def after_sign_in_path_for(resource)
    user_dashboard_path || root_path
  end

  def set_timezone
  	Time.zone = cookies[:moodcall_timezone] || "Eastern Time (US & Canada)"
  end

  def set_dts
    @dts = params[:datetime] ? Date.parse(params[:datetime]) : Time.zone.now
  end
end
