class RatingsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_counseling_session
  before_action :set_rating, only: [:show, :edit, :update, :destroy]

  # GET /ratings
  # GET /ratings.json
  def index
    @ratings = Rating.all
  end

  # GET /ratings/1
  # GET /ratings/1.json
  def show
  end

  # GET /ratings/new
  def new
    @counseling_session = current_user.counseling_sessions.find(params[:counseling_session_id])
    @rating          = @counseling_session.build_rating
  end

  # GET /ratings/1/edit
  def edit
  end

  # POST /ratings
  # POST /ratings.json
  def create
    @rating                    = current_user.ratings.new(rating_params)
    @rating.counseling_session = @counseling_session
    @rating.rateable           = @counseling_session.counselor

    respond_to do |format|
      if @rating.save
        format.html { redirect_to counselor_path(@counseling_session.counselor), notice: "Your Rating for #{@counseling_session.counselor.user.name} has been saved" }
        format.json { render :show, status: :created, location: @rating }
      else
        format.html { render :new }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ratings/1
  # DELETE /ratings/1.json
  def destroy
    @rating.destroy
    respond_to do |format|
      format.html { redirect_to ratings_url, notice: 'Rating was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_counseling_session
      @counseling_session = current_user.counseling_sessions.find(params[:counseling_session_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_rating
      @rating = Rating.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rating_params
      params.require(:rating).permit(:comment,
                                     :stars,
                                     :counseling_session_id)
    end
end
