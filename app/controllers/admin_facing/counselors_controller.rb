require 'admin_facing/admin_facing_controller.rb'
class AdminFacing::CounselorsController < AdminFacingController
  respond_to :html, :json

  # GET /counselors
  # GET /counselors.json
  def index
    @counselors = Counselor.joins(:user).order('last_name').paginate(:page => params[:page], :per_page => 15)
    @page_title    = "Counselors"
    @page_subtitle = ""
  end

  def getCounselors

  	sortby = params[:sortby]
  	if sortby == "last_name" or sortby == "is_active" or sortby == "created_at" or sortby == "email" or sortby == "phone"
		@counselors = Counselor.joins(:user).order(sortby)
	elsif sortby == "popularity"
		@counselors = Counselor.joins(:user).sort_by(&:popularity)
	elsif sortby == "session_rate_in_dollars"
		@counselors = Counselor.joins(:user).sort_by(&:session_rate_in_dollars)
	elsif sortby == "session_fee_in_dollars"
		@counselors = Counselor.joins(:user).sort_by(&:session_fee_in_dollars)
	elsif sortby == "payable_total_in_dollars"
		@counselors = Counselor.joins(:user).sort_by(&:payable_total_in_dollars)
	elsif sortby == "payable_sessions_count"
		@counselors = Counselor.joins(:user).sort_by(&:payable_sessions_count)
	elsif sortby == "counseling_sessions_count"
		@counselors = Counselor.joins(:user).sort_by(&:counseling_sessions_count)
	end

	if params[:order] == "ASC"
		@counselors = @counselors.paginate(:page => params[:page], :per_page => 15)
	else
		@counselors = @counselors.reverse.paginate(:page => params[:page], :per_page => 15)
	end	
    @page_title    = "Counselors"
    @page_subtitle = ""
    render :layout => false

  end

end
