require 'admin_facing/admin_facing_controller.rb'
class AdminFacing::CounselorsController < AdminFacingController
  respond_to :html, :json

  # GET /counselors
  # GET /counselors.json
  def index
    @specialty = Specialty.find(1)

    if params[:specialty]
      @specialty = Specialty.find_by_name "#{params[:specialty]}"
    end

    @counselors = @specialty.counselors
    @page_title    = "Counselors"
    @page_subtitle = ""
  end

end
