class CounselorsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_action :set_counselor, only: [:update_bank, :show, :edit, :update, :destroy, :payouts, :upcoming, :availability, :licenses, :certifications, :education]
  respond_to :html, :json

  # GET /counselors
  # GET /counselors.json
  def index
    @specialty = Specialty.where(:is_active => true, :set_default => 1).first

    if params[:specialty]
      @specialty = Specialty.find_by_name "#{params[:specialty]}"
    end

    if params[:gender] == "Female"
      gender = 2
    elsif params[:gender] == "Male"
      gender = 1
    else
      gender = nil
    end

    if params[:sortby] and params[:sortby] != ""
      sortby = params[:sortby]
    else
      sortby = "availability"
    end

    if params[:counselor_name] and params[:counselor_name] != ""
      name = params[:counselor_name]
      query = "specializations.specialty_id= #{@specialty.id} or first_name ilike? or last_name ilike?"
    else
      name = ""
      query = "specializations.specialty_id= #{@specialty.id}"
    end

    if sortby == "popularity"
      @sortApplied = Counselor.joins(:user,:specializations,:availability_dates).where("#{query}", "%#{name}%","%#{name}%").distinct("counselor.id").active_counselors.sort_by(&:popularity).reverse
    elsif sortby == "low-fee"
      @sortApplied = Counselor.joins(:user,:specializations,:availability_dates).where("#{query}", "%#{name}%","%#{name}%").distinct("counselor.id").active_counselors.sort_by(&:hourly_rate_in_cents)
    elsif sortby == "high-fee"
      @sortApplied = Counselor.joins(:user,:specializations,:availability_dates).where("#{query}", "%#{name}%","%#{name}%").distinct("counselor.id").active_counselors.sort_by(&:hourly_rate_in_cents).reverse
    else
      @sortApplied = Counselor.joins(:user,:specializations,:availability_dates).where("#{query}", "%#{name}%","%#{name}%").distinct("counselor.id").active_counselors.sort_by(&:created_at).reverse
    end
    
    @available_counselors = Array.new
    @sDate = @dts.in_time_zone
    @iterator = 0

    if @sortApplied.length > 0

      while @iterator <= 6

        @lpnum = 0
        @nextAvailed = @thisDts = @sDate
        @available_counselors[@iterator] = {}
        @available_counselors[@iterator]['counselors'] = Array.new

        while @available_counselors[@iterator]['counselors'].length <= 0 and @nextAvailed != ""
          @available_counselors[@iterator]['counselors'] = @sortApplied.select do |c|

            if c.available_after(@thisDts).present? and 
              if gender.present?
                c.user.gender == gender
              else
                c.user.gender.present?
              end
              ctime = c.available_after(@thisDts).in_time_zone
              # ctime = Date.strptime("#{ctime}", "%m/%d/%Y")
              if @lpnum == 0 and ctime >= @sDate.beginning_of_day
                @nextAvailed = ctime
                @lpnum = 1
              elsif ctime < @nextAvailed and ctime >= @sDate.beginning_of_day
                @nextAvailed = ctime
              end
            end

            c.availability_by_dts(@thisDts).present? and
            if gender.present?
              c.user.gender == gender
            else
              c.user.gender.present?
            end
          end

          if @nextAvailed.beginning_of_day != @sDate.beginning_of_day
            @thisDts = @nextAvailed
          else
            @nextAvailed = ""
          end
        end
        if @available_counselors[@iterator]['counselors'].length > 0
          @available_counselors[@iterator]['date'] = @thisDts
          @sDate = @thisDts+1.day
          @iterator = @iterator+1
        else
          break
        end
      end
    else
      @available_counselors[@iterator] = {}
      @available_counselors[@iterator]['counselors'] = Array.new
    end
    
    @counselorsArr = @available_counselors
    # @counselorsArr = @available_counselors.reverse.paginate(:page => params[:page], :per_page => 15)

    @sortby = sortby
    @page_title = "Search Counselors"
    @page_subtitle = "Find the right counselor for you."
  end

  # GET /counselors/1
  # GET /counselors/1.json
  def show
    unless @counselor.is_active or user_can_access_counselor
      redirect_to counselors_path, :notice => "The counselor you're looking for is not currently available. Please search and select an active counselor."
    else

      if current_user and current_user.id != @counselor.user.id and !session[:profileViews].include?(@counselor.id)
        @counselor.update_columns(:profile_view => @counselor.profile_view+1)
        session[:profileViews].push(@counselor.id)
      elsif !current_user
        @ip = request.ip
        if !ProfileView.where(:ip => @ip, :counselor_id => @counselor.id).present?
          @profileView = ProfileView.new(:ip => @ip, :counselor_id => @counselor.id)
          @profileView.save
          @counselor.update_columns(:profile_view => @counselor.profile_view+1)
        end
      end
      @hide_search = true
      @page_title    = "#{@counselor.user.name}"
      @page_subtitle = "A counselor, specializing in #{@counselor.specialties.map {|specialty| specialty.name}.join(",")}"
    end
  end

  def payouts
    unless @counselor.is_active and user_can_access_counselor
      redirect_to counselor_url, :notice => "You can not edit the counselor."
    else
      @tab_name = 'payouts'
      @hide_search = true
      @payouts = @counselor.user.payouts.where.not(:stripe_transfer_id => nil).order(:funds_sent_dts => :desc).all
      @page_title    = "#{@counselor.user.name} Payouts"
      @page_subtitle = ""

      respond_to do |format|
        format.html
        format.csv { send_data @payouts.to_csv }
      end
    end
    
  end

  def upcoming
    unless @counselor.is_active and user_can_access_counselor
      redirect_to counselor_url, :notice => "You can not access the counselor."
    else
      @tab_name = 'upcoming'
      @hide_search = true
      @payouts = @counselor.user.payouts.where(:stripe_transfer_id => nil).all
      @page_title    = "#{@counselor.user.name} Upcoming Payouts"
      @page_subtitle = ""
    end
    respond_to do |format|
      format.html
      format.csv { send_data @payouts.to_csv }
    end
  end

  # GET /counselors/new
  def new
    if current_user.counselor.present?
      redirect_to counselor_url(current_user.counselor), notice: 'You already have a Counselor with MoodyCall. Take a look at your profile listed below.'
    else
      @counselor = Counselor.new
      @counselor.bio = "I'm passionate about helping people reach their full potential. I look forward to leveraging my professional experience to help you reach yours. Schedule a session with me today!"
    end
    @page_title    = "Become a Counselor"
    @page_subtitle = "Join MoodyCall as a counselor."
  end

  # GET /counselors/1/edit
  def edit
    
    unless @counselor.is_active and user_can_access_counselor
      redirect_to counselor_url, :notice => "You can not edit the counselor."
    else
      unless @counselor.counseling_licenses.present?
        @counselor.counseling_licenses.build
      end
      unless @counselor.counseling_certifications.present?
        @counselor.counseling_certifications.build
      end
      @page_title    = "Edit Your Profile"
      @page_subtitle = ""
    end
  end

  def licenses
    unless @counselor.is_active and user_can_access_counselor
      redirect_to counselor_url, :notice => "You can not edit the counselor."
    else
      unless @counselor.counseling_licenses.present?
        @counselor.counseling_licenses.build
      end

      @page_title    = "Edit Your Profile"
      @page_subtitle = ""
    end
  end

  def certifications
    unless @counselor.is_active and user_can_access_counselor
      redirect_to counselor_url, :notice => "You can not edit the counselor."
    else
      unless @counselor.counseling_certifications.present?
        @counselor.counseling_certifications.build
      end

      @page_title    = "Edit Your Profile"
      @page_subtitle = ""
    end
  end

  def education
    unless @counselor.is_active and user_can_access_counselor
      redirect_to counselor_url, :notice => "You can not edit the counselor."
    else
      unless @counselor.counseling_degrees.present?
        @counselor.counseling_degrees.build
      end

      @page_title    = "Edit Your Profile"
      @page_subtitle = ""
    end
  end

  def availability
    unless @counselor.is_active and user_can_access_counselor
      redirect_to counselor_url, :notice => "You can not edit the counselor."
    else
      @page_title    = "Availability for #{@counselor.user.name}"
      @page_subtitle = ""
      
      if request.put?
        handle_availability_intervals
      end
    end
  end

  def update_bank
    if @counselor.user.stripe_recipient_id.present?
      recipient = Stripe::Recipient.retrieve(@counselor.user.stripe_recipient_id)
      recipient.bank_account = params[:stripeToken]
      recipient.save
    else
      recipient = Stripe::Recipient.create(
        :name => @counselor.user.name,
        :type => "individual",
        :email => @counselor.user.email,
        :bank_account => params[:stripeToken]
      )
      @counselor.user.stripe_recipient_id = recipient.id
      @counselor.user.save!
    end

    redirect_to :back, :notice => "Bank information was successfully updated. New payout will be deposited into new bank account."
  end

  # POST /counselors
  # POST /counselors.json
  def create
    @counselor = current_user.build_counselor(counselor_params)

    respond_to do |format|
      if @counselor.save
        format.html { redirect_to education_counselor_url(current_user.counselor, :host => Rails.configuration.action_mailer.default_url_options[:host]), notice: 'Your profile has been created. It will be publically visible once activated by an admin. Please complete additional professional information.' }
        format.json { render :show, status: :created, location: @counselor }
      else
        format.html { render :new }
        format.json { render json: @counselor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /counselors/1
  # PATCH/PUT /counselors/1.json
  def update
    remove_degrees
    remove_licenses
    remove_certifications
    # handle_availability_intervals

    respond_to do |format|
      if @counselor.update(counselor_params)
        format.html { redirect_to :back, notice: 'Counselor was successfully updated.' }
        format.json { render :show, status: :ok, location: @counselor }
      else
        format.html { render :edit }
        format.json { render json: @counselor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /counselors/1
  # DELETE /counselors/1.json
  def destroy
    @counselor.destroy
    respond_to do |format|
      format.html { redirect_to counselors_url, notice: 'Counselor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_counselor
      @counselor = Counselor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def counselor_params
      params.require(:counselor).permit(:bio,
                                        :photo,
                                        :profession_start_date,
                                        :slug,
                                        :user_id,
                                        :hourly_rate_in_cents,
                                        :hourly_fee_in_cents,
                                        :send_session_sms_alerts,
                                        :send_session_email_alerts,
                                        :advanced_scheduling_in_weeks,
                                        :available_monday,
                                        :available_tuesday,
                                        :available_wednesday,
                                        :available_thursday,
                                        :available_friday,
                                        :available_saturday,
                                        :available_sunday,
                                        :is_active,
                                        { :specialty_ids => [] },
                                        availability_intervals_attributes: [:day_of_week, :start_time, :end_time, :timezone_name],
                                        counseling_licenses_attributes: [:id, :license_number, :license_type, :state, :established_on_date],
                                        counseling_certifications_attributes: [:id, :name],
                                        counseling_degrees_attributes: [:id, :degree_type, :name, :institution, :year_of_completion])
    end

    # def availability_params
    #   params.require(:counselor).permit(:availability_intervals_attributes)
    # end

  protected

  def remove_certifications
    if params[:counselor][:counseling_certifications_attributes].present?
      params[:counselor][:counseling_certifications_attributes].each do |c|
        unless c[1][:name].present?
          if c[1][:id].present?
            degree = CounselingCertification.find(c[1][:id])
            degree.destroy
            params[:counselor][:counseling_certifications_attributes].delete(c[0])
          end
        end
      end
    end
  end

  def remove_licenses
    if params[:counselor][:counseling_licenses_attributes].present?
      params[:counselor][:counseling_licenses_attributes].each do |c|
        unless c[1][:license_number].present?
          if c[1][:id].present?
            degree = CounselingLicense.find(c[1][:id])
            degree.destroy
            params[:counselor][:counseling_licenses_attributes].delete(c[0])
          end
        end
      end
    end
  end

  def remove_degrees
    if params[:counselor][:counseling_degrees_attributes].present?
      params[:counselor][:counseling_degrees_attributes].each do |c|
        unless c[1][:degree_type].present?
          if c[1][:id].present?
            degree = CounselingDegree.find(c[1][:id])
            degree.destroy
            params[:counselor][:counseling_degrees_attributes].delete(c[0])
          end
        end
      end
    end
  end

  def handle_availability_intervals
    # We want to build from scratch when counselor updates their availability
    availability_params = Array.new
    if params[:counselor][:availability]
      type = params[:counselor][:availability]
      @counselor.availability_dates.destroy_all
      params[:counselor][type].to_a.each do |row|
        if row[1][:availability_dates_attributes].present?

          availability_params = row[1][:availability_dates_attributes]

          temp_start_date = availability_params[:start_date].split('/')
          availability_params[:start_date] = "#{temp_start_date[1]}/#{temp_start_date[0]}/#{temp_start_date[2]}"
          
          if !availability_params[:end_date].present?
            availability_params[:end_date] = availability_params[:start_date]
            availability_params[:is_same_time] = 1
            availability_params[:is_specific] = 1
            wd = DateTime.parse(availability_params[:start_date]).strftime('%w')
            row[1][:week_days] = [wd]
          else
            temp_end_date = availability_params[:end_date].split('/')
            availability_params[:end_date] = "#{temp_end_date[1]}/#{temp_end_date[0]}/#{temp_end_date[2]}"
          end
          
          @availabilityDate = @counselor.availability_dates.new(availability_params)
          @availabilityDate.save
          row[1][:week_days].to_a.each do |day|

            dayIndex = day
            if availability_params[:is_same_time].present?
              dayIndex = "0"
            end
            row[1][:availability_intervals_attributes][dayIndex].each do |t|
              original_start_time = t[1][:start_time]
              original_end_time   = t[1][:end_time]
              start_time_as_utc   = Time.zone.parse(original_start_time).utc.strftime("%I:%M%P")
              end_time_as_utc     = Time.zone.parse(original_end_time).utc.strftime("%I:%M%P")
              # We want to store UTC time for consistancy
              availabilityTime = {}
              # availabilityTime[:start_time] = start_time_as_utc
              # availabilityTime[:end_time]   = end_time_as_utc
              availabilityTime[:start_time] = original_start_time
              availabilityTime[:end_time]   = original_end_time
              availabilityTime[:day_of_week] = day
              availabilityTime[:timezone_name] = Time.zone.name
              @availabilityDate.availability_intervals.new(availabilityTime).save
            end
            
          end

        else
          # params[:counselor][:availability_intervals_attributes].delete(time[0])
        end
      end
    end
  end

  def user_can_access_counselor
    if current_user and current_user.is_admin
      true
    elsif current_user and @counselor.user == current_user
      true
    else
      false
    end   
  end

  def authenticate_user!
    if user_signed_in?
      super
    else
      redirect_to new_user_registration_path, :notice => "Let's get you started. Please enter your name, email, and password."
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end
end
