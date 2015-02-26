require 'admin_facing/admin_facing_controller.rb'
class AdminFacing::CounselorsController < AdminFacingController
  respond_to :html, :json

  # GET /counselors
  # GET /counselors.json
  def index
    @counselors = Counselor.paginate(:page => params[:page], :per_page => 15)
    @page_title    = "Counselors"
    @page_subtitle = ""
  end

end
