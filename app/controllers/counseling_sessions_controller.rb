class CounselingSessionsController < ApplicationController
  before_action :set_counseling_session, only: [:show, :edit, :update, :destroy]

  # GET /counseling_sessions
  # GET /counseling_sessions.json
  def index
    @counseling_sessions = CounselingSession.all
  end

  # GET /counseling_sessions/1
  # GET /counseling_sessions/1.json
  def show
  end

  # GET /counseling_sessions/new
  def new
    @counseling_session = CounselingSession.new
  end

  # GET /counseling_sessions/1/edit
  def edit
  end

  # POST /counseling_sessions
  # POST /counseling_sessions.json
  def create
    @counseling_session                = current_user.counseling_sessions.new(counseling_session_params)
    @counseling_session.start_datetime = Time.zone.parse("#{params[:counseling_session][:day]} #{params[:counseling_session][:time]}").utc

    respond_to do |format|
      if @counseling_session.save
        format.html { redirect_to @counseling_session, notice: 'Counseling session was successfully created.' }
        format.json { render :show, status: :created, location: @counseling_session }
      else
        format.html { render :new }
        format.json { render json: @counseling_session.errors, status: :unprocessable_entity }
      end
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
