class CounselorsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :getCounselors]
  before_filter :checkIsCounselor!, except: [:new,:create]
  before_action :set_counselor, only: [:update_bank, :show, :edit, :update, :destroy, :payouts, :upcoming, :availability, :licenses, :certifications, :education]
  respond_to :html, :json

  # GET /counselors
  # GET /counselors.json
  def index
    @thisDate = @dts.in_time_zone.utc.strftime("%Y-%m-%d %H:%M:%S")
    @specialty = Specialty.where(:is_active => true, :set_default => 1).first

    if params[:specialty]
      @specialty = Specialty.find_by_name "#{params[:specialty]}"
    end

    if params[:gender] == "Female"
      gender = 2
    elsif params[:gender] == "Male"
      gender = 1
    else
      gender = "1,2"
    end

    if params[:sortby] and params[:sortby] != ""
      sortby = params[:sortby]
    else
      sortby = "availability"
    end

    limit = 2

    if params[:counselor_name] and params[:counselor_name] != ""
      name = params[:counselor_name].downcase
      # query = "(counselors.is_active=true and users.gender in (#{gender})) and specializations.specialty_id= #{@specialty.id} and (users.first_name like '%#{name}%' or users.last_name like '%#{name}%' or concat(users.first_name, ' ', users.last_name) like '%#{name}%')"
      query = "(counselors.is_active=true and (LOWER(trim(users.first_name)) like '%#{name}%' or LOWER(trim(users.last_name)) like '%#{name}%' or concat(LOWER(trim(users.first_name)), ' ', LOWER(trim(users.last_name))) like '%#{name}%'))"
      @thisDate = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
      @dts = Time.now.in_time_zone
    else
      name = ""
      query = "(counselors.is_active=true and users.gender in (#{gender})) and specializations.specialty_id= #{@specialty.id}"
    end
    curentUtc = (Time.now.utc + 30.minutes).strftime("%Y-%m-%d %H:%M:%S")
    
    upcomingDates = AvailabilityDay.find_by_sql(
      "select distinct (availability_days.start_datetime) as start_datetime 
      from availability_days 
      inner join counselors on counselors.id = availability_days.counselor_id 
      where availability_days.available_datetime >= '#{@thisDate}' and availability_days.available_datetime > '#{curentUtc}' and availability_days.active=true and counselors.id in (
        select counselors.id from counselors 
        inner join users on users.id = counselors.user_id 
        inner join specializations on specializations.counselor_id = counselors.id
        where #{query})
      order by start_datetime limit 50")
    
    @iterator = 0
    existDateArr = []
    dateIdsArr = {}
    @available_counselors = Array.new
    
    upcomingDates.each do |upcoming|
      if !existDateArr.include?(upcoming.start_datetime.strftime("%Y-%m-%d"))
        if(existDateArr.length < 1)
          existDateArr.push(upcoming.start_datetime.strftime("%Y-%m-%d"))
          dateIdsArr[upcoming.start_datetime.strftime("%Y-%m-%d")] = ""
          dtime = upcoming.start_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
          dateIdsArr[upcoming.start_datetime.strftime("%Y-%m-%d")] += "'#{dtime}',"
        else
          break
        end
      else 
        dtime = upcoming.start_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
        dateIdsArr[upcoming.start_datetime.strftime("%Y-%m-%d")] += "'#{dtime}',"
      end

    end
    
    existDateArr.each do |upcoming|

      datearr   = dateIdsArr[upcoming].chop
      curentUtc = (Time.now.utc + 30.minutes).strftime("%Y-%m-%d %H:%M:%S")
      dateQuery = "availability_days.active=true and availability_days.available_datetime>='#{@thisDate}' and availability_days.available_datetime >'#{curentUtc}' and availability_days.start_datetime in (#{datearr})"
      @available_counselors[@iterator] = {}
      @available_counselors[@iterator]['counselors'] = Array.new

      if sortby == "newest"
        @sortApplied = Counselor.includes(:user,:specializations,:availability_days).where("#{dateQuery} and #{query}").references(:availability_days).distinct("counselor.id").order("counselors.created_at DESC")
      elsif sortby == "low-fee"
        @sortApplied = Counselor.includes(:user,:specializations,:availability_days).where("#{dateQuery} and #{query}").references(:availability_days).distinct("counselor.id").order("counselors.hourly_rate_in_cents ASC")
      elsif sortby == "high-fee"
        @sortApplied = Counselor.includes(:user,:specializations,:availability_days).where("#{dateQuery} and #{query}").references(:availability_days).distinct("counselor.id").order("counselors.hourly_rate_in_cents DESC")
      elsif sortby == "popularity"
        @sortApplied = Counselor.includes(:user,:specializations,:availability_days).where("#{dateQuery} and #{query}").references(:availability_days).distinct("counselor.id").sort_by(&:popularity).reverse
      else
        @sortApplied = Counselor.includes(:user,:specializations,:availability_days).where("#{dateQuery} and #{query}").references(:availability_days).distinct("counselor.id").order("availability_days.available_datetime ASC").sort_by(&:availabilitytime)
      end

      @totalCount = @sortApplied.length
      @available_counselors[@iterator]['date'] = @sortApplied.first(1)[0].availability_days.first(1)[0].available_datetime
      @available_counselors[@iterator]['counselors'] = @sortApplied.first(limit)
      @iterator += 1
    end
    
    @counselorsArr = @available_counselors

    @sortby = sortby
    @page_title = "Search Counselors"
    @page_subtitle = "Find the right counselor for you."
  end

  def getCounselors
    @thisDate = @dts.in_time_zone.utc.strftime("%Y-%m-%d %H:%M:%S")
    @specialty = Specialty.where(:is_active => true, :set_default => 1).first

    if params[:specialty]
      @specialty = Specialty.find_by_name "#{params[:specialty]}"
    end

    if params[:gender] == "Female"
      gender = 2
    elsif params[:gender] == "Male"
      gender = 1
    else
      gender = "1,2"
    end

    if params[:sortby] and params[:sortby] != ""
      sortby = params[:sortby]
    else
      sortby = "availability"
    end

    ofset = params['offset'].to_i
    limit = params['limit'].to_i
    newofset = ofset+limit

    if params[:counselor_name] and params[:counselor_name] != ""
      name = params[:counselor_name].downcase
      # query = "(counselors.is_active=true and users.gender in (#{gender})) and specializations.specialty_id= #{@specialty.id} and (users.first_name like '%#{name}%' or users.last_name like '%#{name}%' or concat(users.first_name, ' ', users.last_name) like '%#{name}%')"
      query = "(counselors.is_active=true and (LOWER(users.first_name) like '%#{name}%' or LOWER(users.last_name) like '%#{name}%' or concat(LOWER(users.first_name), ' ', LOWER(users.last_name)) like '%#{name}%'))"
      @thisDate = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
      @dts = Time.now.in_time_zone
    else
      name = ""
      query = "(counselors.is_active=true and users.gender in (#{gender})) and specializations.specialty_id= #{@specialty.id}"
    end
    curentUtc = (Time.now.utc + 30.minutes).strftime("%Y-%m-%d %H:%M:%S")
    
    upcomingDates = AvailabilityDay.find_by_sql(
      "select distinct (availability_days.start_datetime) as start_datetime 
      from availability_days 
      inner join counselors on counselors.id = availability_days.counselor_id 
      where available_datetime >= '#{@thisDate}' and available_datetime > '#{curentUtc}' and active=true and counselors.id in (
        select counselors.id from counselors 
        inner join users on users.id = counselors.user_id 
        inner join specializations on specializations.counselor_id = counselors.id
        where #{query})
      order by start_datetime limit 50")
    
    @iterator = 0
    existDateArr = []
    dateIdsArr = {}
    @available_counselors = Array.new

    upcomingDates.each do |upcoming|
      if !existDateArr.include?(upcoming.start_datetime.strftime("%Y-%m-%d"))
        if(existDateArr.length < 1)
          existDateArr.push(upcoming.start_datetime.strftime("%Y-%m-%d"))
          dateIdsArr[upcoming.start_datetime.strftime("%Y-%m-%d")] = ""
          dtime = upcoming.start_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
          dateIdsArr[upcoming.start_datetime.strftime("%Y-%m-%d")] += "'#{dtime}',"
        else
          break
        end
      else 
        dtime = upcoming.start_datetime.utc.strftime("%Y-%m-%d %H:%M:%S")
        dateIdsArr[upcoming.start_datetime.strftime("%Y-%m-%d")] += "'#{dtime}',"
      end

    end
    
    existDateArr.each do |upcoming|

      datearr   = dateIdsArr[upcoming].chop
      curentUtc = (Time.now.utc + 30.minutes).strftime("%Y-%m-%d %H:%M:%S")
      dateQuery = "availability_days.active=true and availability_days.available_datetime>='#{@thisDate}' and availability_days.available_datetime >'#{curentUtc}' and availability_days.start_datetime in (#{datearr})"
      @available_counselors[@iterator] = {}
      @available_counselors[@iterator]['counselors'] = Array.new

      if sortby == "newest"
        @sortApplied = Counselor.includes(:user,:specializations,:availability_days).where("#{dateQuery} and #{query}").references(:availability_days).distinct("counselor.id").order("counselors.created_at DESC").offset(ofset).limit(limit)
      elsif sortby == "low-fee"
        @sortApplied = Counselor.includes(:user,:specializations,:availability_days).where("#{dateQuery} and #{query}").references(:availability_days).distinct("counselor.id").order("counselors.hourly_rate_in_cents ASC").offset(ofset).limit(limit)
      elsif sortby == "high-fee"
        @sortApplied = Counselor.includes(:user,:specializations,:availability_days).where("#{dateQuery} and #{query}").references(:availability_days).distinct("counselor.id").order("counselors.hourly_rate_in_cents DESC").offset(ofset).limit(limit)
      elsif sortby == "popularity"
        @sortApplied = Counselor.includes(:user,:specializations,:availability_days).where("#{dateQuery} and #{query}").references(:availability_days).distinct("counselor.id").sort_by(&:popularity).reverse.first(newofset).last(limit)
      else
        @sortApplied = Counselor.includes(:user,:specializations,:availability_days).where("#{dateQuery} and #{query}").references(:availability_days).distinct("counselor.id").order("availability_days.available_datetime ASC").sort_by(&:availabilitytime).first(newofset).last(limit)
      end

      @available_counselors[@iterator]['date'] = @sortApplied.first(1)[0].availability_days.first(1)[0].available_datetime
      @available_counselors[@iterator]['counselors'] = @sortApplied
      @iterator += 1
    end
    
    @counselorsArr = @available_counselors

    @sortby = sortby
    @page_title = "Search Counselors"
    @page_subtitle = "Find the right counselor for you."
    @ofset = ofset
    render :layout => false
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
    unless user_can_access_counselor
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
    unless user_can_access_counselor
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
      redirect_to counselor_url(current_user.counselor), notice: 'Good news! You are already a Counselor with MoodyCall. See your profile below.'
    elsif !current_user.is_counselor
      redirect_to user_dashboard_url, notice: 'You must first log out to access this page.'
    else
      @hide_search = true
      @counselor = Counselor.new
      @counselor.bio = "I'm passionate about helping people reach their full potential. I look forward to leveraging my professional experience to help you reach yours. Schedule a session with me today!"
    end
    @page_title    = "Become a Counselor"
    @page_subtitle = "Join MoodyCall as a counselor."
  end

  # GET /counselors/1/edit
  def edit
    
    unless user_can_access_counselor
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
    unless user_can_access_counselor
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
    unless user_can_access_counselor
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
    unless user_can_access_counselor
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
    unless user_can_access_counselor
      redirect_to counselor_url, :notice => "You can not edit the counselor."
    else
      @page_title    = "Availability for #{@counselor.user.name}"
      @page_subtitle = ""
      
      if request.put?
        handle_availability_intervals
        flash[:notice] = "Availability Updated Successfully"
      end
    end
  end

  def update_bank

    err = "Bank information was successfully updated. New payout will be deposited into new bank account."
    if @counselor.user.stripe_recipient_id.present?

      begin
        recipient = Stripe::Account.retrieve(@counselor.user.stripe_recipient_id)
        recipient.external_account = params[:stripeToken]
        
        if params[:type] == 'individual'
          recipient.legal_entity = {
            :first_name => params[:first_name],
            :last_name => params[:last_name],
            :type => params[:type],
            :dob => {
              :day => params[:day], 
              :month => params[:month], 
              :year => params[:year]
            },
            :address => {
              :city => params[:city],
              :line1 => params[:address],
              :postal_code => params[:postal_code],
              :state => params[:state]
              },
            :ssn_last_4 => params[:ssn].last(4)
          }
        else
          recipient.legal_entity = {
            :first_name => params[:first_name],
            :last_name => params[:last_name],
            :type => params[:type],
            :dob => {
              :day => params[:day], 
              :month => params[:month], 
              :year => params[:year]
            },
            :address => {
              :city => params[:city],
              :line1 => params[:address],
              :postal_code => params[:postal_code],
              :state => params[:state]
              },
            :ssn_last_4 => params[:ssn].last(4),
            :business_name => params[:business_name],
            :business_tax_id => params[:ein]
          }
        end

        recipient.tos_acceptance = {
          :date => params[:date],
          :ip => params[:ip]
        }

        recipient.save
      rescue Stripe::StripeError => e
        body = e.json_body
        err  = body[:error][:message]
      end
    else

      begin
        if params[:type] == 'individual'
          recipient = Stripe::Account.create(
            :email => params[:email],
            :managed => true,
            :country => 'US',
            :external_account => params[:stripeToken],
            :legal_entity => {
              :first_name => params[:first_name],
              :last_name => params[:last_name],
              :type => params[:type],
              :dob => {
                :day => params[:day],
                :month => params[:month],
                :year => params[:year]
              },
              :address => {
                :city => params[:city],
                :line1 => params[:address],
                :postal_code => params[:postal_code],
                :state => params[:state]
              },
              :ssn_last_4 => params[:ssn].last(4)
            },
            :tos_acceptance => {
              :date => params[:date],
              :ip => params[:ip]
            }
          )
        else
          recipient = Stripe::Account.create(
            :email => params[:email],
            :managed => true,
            :country => 'US',
            :external_account => params[:stripeToken],
            :legal_entity => {
              :first_name => params[:first_name],
              :last_name => params[:last_name],
              :type => params[:type],
              :dob => {
                :day => params[:day],
                :month => params[:month],
                :year => params[:year]
              },
              :address => {
                :city => params[:city],
                :line1 => params[:address],
                :postal_code => params[:postal_code],
                :state => params[:state]
              },
              :business_name => params[:business_name],
              :business_tax_id => params[:ein],
              :ssn_last_4 => params[:ssn].last(4)
            },
            :tos_acceptance => {
              :date => params[:date],
              :ip => params[:ip]
            }
          )
        end
      rescue Stripe::StripeError => e
        body = e.json_body
        err  = body[:error][:message]
      else
        @counselor.user.stripe_recipient_id = recipient.id
        @counselor.user.save!
      end
    end

    redirect_to :back, :notice => "#{err}"
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

      if(params[:counselor][:hourly_rate_in_dollars])
        params[:counselor][:hourly_rate_in_cents] = params[:counselor][:hourly_rate_in_dollars].to_f*100
        params[:counselor][:hourly_fee_in_cents] = params[:counselor][:hourly_fee_in_dollars].to_f*100
      end
      
      if @counselor.update(counselor_params)
        # if @counselor.is_active?
        #   @counselor._create_stripe_recipient_id
        # end
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
                                        :phone,
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

      @counselor.availability_dates.destroy_all
      if !params[:counselor][:clear_date].present?

        type = params[:counselor][:availability]
        params[:counselor][type].to_a.each do |row|
          if row[1][:availability_dates_attributes].present?

            availability_params = row[1][:availability_dates_attributes]
            
            temp_start_date = availability_params[:start_date].split('/')
            start_date = "#{temp_start_date[1]}/#{temp_start_date[0]}/#{temp_start_date[2]}"
            
            if !availability_params[:end_date].present?
              end_date = start_date
              availability_params[:is_same_time] = 1
              availability_params[:is_specific] = 1
              wd = DateTime.parse(start_date).strftime('%w')
              row[1][:week_days] = [wd]
            else
              temp_end_date = availability_params[:end_date].split('/')
              end_date = "#{temp_end_date[1]}/#{temp_end_date[0]}/#{temp_end_date[2]}"
            end

            availability_params[:start_date] = start_date
            availability_params[:end_date] = end_date

            @availabilityDate = @counselor.availability_dates.new(availability_params)
            @availabilityDate.save

            weekDayStr = "{"
            row[1][:week_days].to_a.each do |day|

              dayIndex = day
              if availability_params[:is_same_time].present?
                dayIndex = "0"
              end

              row[1][:availability_intervals_attributes][dayIndex].each do |t|
                availabilityTime = {}
                original_start_time = t[:start_time]
                original_end_time   = t[:end_time]
                availabilityTime[:start_time] = Time.zone.parse(original_start_time).strftime("%H:%M%P")
                availabilityTime[:end_time]   = Time.zone.parse(original_end_time).strftime("%H:%M%P")
                availabilityTime[:day_of_week] = day
                availabilityTime[:timezone_name] = Time.zone.name
                @availabilityDate.availability_intervals.new(availabilityTime).save
              end
              weekDayStr += "#{day},"
            end
            weekDayStr = weekDayStr.chop
            weekDayStr += "}"
            sd = Date.parse(start_date).strftime("%Y-%m-%d")
            ed = Date.parse(end_date).strftime("%Y-%m-%d")
            tz = Time.zone.now.strftime('%Z')
            arr = row[1][:availability_intervals_attributes].to_json
            issametime = 0
            if availability_params[:is_same_time].present?
              issametime = 1
            end
            
            ActiveRecord::Base.connection.execute("select fn_set_availability_day(#{@counselor.id},#{@availabilityDate.id},'#{sd}','#{ed}','#{weekDayStr}','#{arr}','#{tz}','#{issametime}');")
          end
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
      redirect_to new_user_registration_path(:q => "counselor"),:notice => "Let's get you started. Please enter your name, email, and password."
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end

  def checkIsCounselor!
    if user_signed_in? and current_user.is_counselor and !current_user.counselor.present?
      redirect_to new_counselor_path, :notice => "Please fill in the form to continue"
    end
  end
end
