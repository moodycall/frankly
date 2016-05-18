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

  def deleteCounselors
  	id = params['id'];
  	@counselor = Counselor.find(id);
  	# @upcomingSessions = @counselor.upcoming_sessions
  	# @upcomingSessions.each do |session|
	# 	session.cancelled_on_dts = Time.now
	# 	session.save
	# 	bookedtimes = "'#{session.start_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")}'"
	# 	if session.estimate_duration_in_minutes == 60
	# 		nextTime = (session.start_datetime.utc + 30.minutes).strftime("%Y-%m-%d %H:%M:%S")
	# 		bookedtimes += ",'#{nextTime}'"
	# 	end
	# 	availability = AvailabilityDay.where("counselor_id=#{session.counselor_id} and available_datetime in (#{bookedtimes})")
	# 	availability.each do |t|
	# 		t.update(:active=>true)
	# 	end

	# 	if session.is_refundable
	# 		if session.stripe_charge_id.present? and session.issue_refund
	# 			  CounselorMailer.client_cancellation(session.id).deliver
	# 			  UserMailer.counseling_session_cancellation(session.id).deliver
	# 		else
	# 			  CounselorMailer.client_cancellation(session.id).deliver
	# 			  UserMailer.counseling_session_cancellation(session.id).deliver
	# 		end
	# 	else
	# 		CounselorMailer.client_cancellation(session.id).deliver
	# 		UserMailer.counseling_session_cancellation(session.id).deliver
	# 	end
	# end
	
	name = @counselor.user.first_name
	email= @counselor.user.email
  	if @counselor.user.delete and @counselor.delete

  		CounselorMailer.counselor_deleted(name,email).deliver
	  	respond_to do |format|
		    format.json { render json: {"status" => "success"}}
		end
  	end
  end

end
