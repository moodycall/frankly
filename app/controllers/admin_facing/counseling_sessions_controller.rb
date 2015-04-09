require 'admin_facing/admin_facing_controller.rb'
class AdminFacing::CounselingSessionsController < AdminFacingController

  def index
    @counseling_sessions = CounselingSession.paginate(:page => params[:page], :per_page => 15)

    @tab_name      = "index"
    @page_title    = "Counseling Sessions"
    @page_subtitle = ""
    
    respond_to do |format|
      format.html
      format.csv { send_data CounselingSession.to_csv }
    end
  end

  def upcoming
    @counseling_sessions = CounselingSession.upcoming_sessions.paginate(:page => params[:page], :per_page => 15)

    @tab_name      = "upcoming"
    @page_title    = "Counseling Sessions"
    @page_subtitle = ""
  end
end
