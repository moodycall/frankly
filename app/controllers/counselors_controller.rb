class CounselorsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_action :set_counselor, only: [:update_bank, :show, :edit, :update, :destroy, :payouts, :availability, :licenses, :certifications, :education]
  respond_to :html, :json

  # GET /counselors
  # GET /counselors.json
  def index
    @specialty = Specialty.find(1)

    if params[:specialty]
      @specialty = Specialty.find_by_name "#{params[:specialty]}"
    end

    @counselors = @specialty.counselors.sort_by(&:popularity).reverse.paginate(:page => params[:page], :per_page => 15)

    @page_title = "Search Counselors"
    @page_subtitle = "Find the right counselor for you."
  end

  # GET /counselors/1
  # GET /counselors/1.json
  def show
    @hide_search = true
    @page_title    = "#{@counselor.user.name}"
    @page_subtitle = "A counselor, specializing in #{@counselor.specialties.map {|specialty| specialty.name}.join(",")}"
  end

  def payouts
    @hide_search = true
    @payouts = @counselor.user.payouts.all
    @page_title    = "#{@counselor.user.name} Payouts"
    @page_subtitle = ""
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
    unless @counselor.counseling_licenses.present?
      @counselor.counseling_licenses.build
    end
    unless @counselor.counseling_certifications.present?
      @counselor.counseling_certifications.build
    end
    @page_title    = "Edit Your Profile"
    @page_subtitle = ""
  end

  def licenses
    unless @counselor.counseling_licenses.present?
      @counselor.counseling_licenses.build
    end
    @page_title    = "Edit Your Profile"
    @page_subtitle = ""
  end

  def certifications
    unless @counselor.counseling_certifications.present?
      @counselor.counseling_certifications.build
    end
    @page_title    = "Edit Your Profile"
    @page_subtitle = ""
  end

  def education
    unless @counselor.counseling_degrees.present?
      @counselor.counseling_degrees.build
    end
    @page_title    = "Edit Your Profile"
    @page_subtitle = ""
  end

  def availability
    @page_title    = "Availability for #{@counselor.user.name}"
    @page_subtitle = ""
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
        format.html { redirect_to @counselor, notice: 'Counselor was successfully created.' }
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

    handle_availability_intervals

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
                                        { :specialty_ids => [] },
                                        availability_intervals_attributes: [:day_of_week, :start_time, :end_time],
                                        counseling_licenses_attributes: [:license_number, :license_type, :state, :established_on_date],
                                        counseling_certifications_attributes: [:name],
                                        counseling_degrees_attributes: [:degree_type, :name, :institution, :year_of_completion])
    end

  protected

  def handle_availability_intervals
    # We want to build from scratch when counselor updates their availability
    if params[:counselor][:availability_intervals_attributes]
      @counselor.availability_intervals.destroy_all
      params[:counselor][:availability_intervals_attributes].to_a.each do |time|
        if time[1][:start_time].present?
          original_start_time = time[1][:start_time]
          original_end_time   = time[1][:end_time]
          start_time_as_utc   = Time.zone.parse(original_start_time).utc.strftime("%I:%M%P")
          end_time_as_utc     = Time.zone.parse(original_end_time).utc.strftime("%I:%M%P")
          # We want to store UTC time for consistancy
          time[1][:start_time] = start_time_as_utc
          time[1][:end_time]   = end_time_as_utc
        else
          params[:counselor][:availability_intervals_attributes].delete(time[0])
        end
      end
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
