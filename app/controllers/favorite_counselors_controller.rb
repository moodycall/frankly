class FavoriteCounselorsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_favorite_counselor, only: [:destroy]

  # GET /favorite_counselors
  # GET /favorite_counselors.json
  def index
    @favorite_counselors = current_user.favorite_counselors.all
  end

  # POST /favorite_counselors
  # POST /favorite_counselors.json
  def create
    @favorite_counselor = current_user.favorite_counselors.new
    @counselor = Counselor.find(params[:counselor])
    @favorite_counselor.counselor = @counselor

    if @favorite_counselor.save
      redirect_to favorite_counselors_path, notice: 'Favorite counselor was successfully created.'
    else
      redirect_to counselor_path(@counselor), notice: "We were unable to favorite this counselor. It's most likely because you have already added them as a favorite."
    end
  end

  # DELETE /favorite_counselors/1
  # DELETE /favorite_counselors/1.json
  def destroy
    @favorite_counselor.destroy
    respond_to do |format|
      format.html { redirect_to favorite_counselors_url, notice: 'Favorite counselor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favorite_counselor
      @favorite_counselor = current_user.favorite_counselors.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def favorite_counselor_params
      params.require(:favorite_counselor).permit(:user_id, :counselor_id)
    end
end
