class CounselorsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_action :set_counselor, only: [:show, :edit, :update, :destroy]

  # GET /counselors
  # GET /counselors.json
  def index
    @counselors = Counselor.all
  end

  # GET /counselors/1
  # GET /counselors/1.json
  def show
  end

  # GET /counselors/new
  def new
    unless current_user.counselor.present?
      @counselor = current_user.build_counselor
      if @counselor.save
        redirect_to counselor_url(@counselor), notice: 'Great! A preview of your profile has been created for you. Update your information to become an active counselor.'
      end
    else
      redirect_to counselor_url(current_user.counselor), notice: 'You already have a Counselor Profile.'
    end
  end

  # GET /counselors/1/edit
  def edit
  end

  # POST /counselors
  # POST /counselors.json
  def create
    @counselor = current_user.counselors.new(counselor_params)

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
    respond_to do |format|
      if @counselor.update(counselor_params)
        format.html { redirect_to @counselor, notice: 'Counselor was successfully updated.' }
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
                                        :available_sunday)
    end
end
