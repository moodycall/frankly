class CounselingSessionsController < ApplicationController
  require "opentok"
  before_action :authenticate_user!, :except => [:create]
  before_action :set_counseling_session, only: [:show, :edit, :update, :destroy]

  # GET /counseling_sessions
  # GET /counseling_sessions.json
  def index
    @counseling_sessions = CounselingSession.all
  end

  # GET /counseling_sessions/1
  # GET /counseling_sessions/1.json
  def show
    api_key    = Rails.configuration.opentok_api_key
    api_secret = Rails.configuration.opentok_api_secret
    opentok    = OpenTok::OpenTok.new api_key, api_secret

    if @counseling_session.opentok_session_id.present?
      @token = opentok.generate_token @counseling_session.opentok_session_id,
          :role        => :moderator,
          :expire_time => @counseling_session.estimated_endtime,
          :data        => "name=#{current_user.name}"
    else
      @counseling_session.create_opentok_session
    end
  end

  # GET /counseling_sessions/new
  def new
    @hide_search = true
    unless session[:pending_session_counselor_id].present?
      redirect_to counselors_path, notice: "Search for a Counselor you would like to schedule a session with."
    else
      @counselor = Counselor.find(session[:pending_session_counselor_id])
      @counseling_session = CounselingSession.new
      @dts = DateTime.parse(session[:pending_session_date])
      session[:pending_session_time]
      session[:pending_session_date]
    end
  end

  # GET /counseling_sessions/1/edit
  def edit
  end

  # POST /counseling_sessions
  # POST /counseling_sessions.json
  def create
    if current_user.present?
      @counseling_session                = current_user.counseling_sessions.new(counseling_session_params)
      @counseling_session.start_datetime = Time.zone.parse("#{params[:counseling_session][:day]} #{params[:counseling_session][:time]}").utc


      if @counseling_session.save
        @counseling_session.create_opentok_session # Create  opentok session for later use
        redirect_to @counseling_session, notice: 'Counseling session was successfully created.'
      else
        render :new
      end
    else
      session[:pending_session_counselor_id] = params[:counseling_session][:counselor_id]
      session[:pending_session_time]         = params[:counseling_session][:time]
      session[:pending_session_date]         = params[:counseling_session][:day]

      redirect_to new_user_registration_path, notice: "Your Session info has been saved. Please signup or signin to continue."
    end
  end

  # PATCH/PUT /counseling_sessions/1
  # PATCH/PUT /counseling_sessions/1.json
  def update
    respond_to do |format|
      if @counseling_session.update(counseling_session_params)
        format.html { redirect_to @counseling_session, notice: 'Counseling session was successfully updated.' }
        format.json { render :show, status: :ok, location: @counseling_session }
      else
        format.html { render :edit }
        format.json { render json: @counseling_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /counseling_sessions/1
  # DELETE /counseling_sessions/1.json
  def destroy
    @counseling_session.destroy
    respond_to do |format|
      format.html { redirect_to counseling_sessions_url, notice: 'Counseling session was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_counseling_session
      @counseling_session = CounselingSession.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def counseling_session_params
      params.require(:counseling_session).permit(:start_datetime, :estimate_duration_in_minutes, :actual_duration_in_minutes, :client_id, :counselor_id, :price_in_cents, :stripe_charge_id, :slug, :secure_id, :refund_amount_in_cents, :payout_id)
    end
end
