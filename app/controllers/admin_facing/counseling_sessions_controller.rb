require 'admin_facing/admin_facing_controller.rb'
class AdminFacing::CounselingSessionsController < AdminFacingController

  def index
    @counseling_sessions = CounselingSession.order(:start_datetime => :desc).all

    @page_title    = "Counseling Sessions"
    @page_subtitle = ""
  end
end
