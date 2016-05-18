require 'admin_facing/admin_facing_controller.rb'
class AdminFacing::GeneralController < AdminFacingController

	def index
		@general = General.new
	end

	def create
		if params[:general][:item] != "" and params[:general][:subject] != "" and params[:general][:content] != ""
		    @general = General.new
		    @general.item = params[:general][:item]
		    @general.subject = params[:general][:subject]
		    @general.content = params[:general][:content]
		    if @general.save
		    	redirect_to :back, :notice => "Successfully updated"
		    else
		    	redirect_to :back, :notice => "#{@general.error}"
		    end
		else
			redirect_to :back, :notice => "Please fill all the fields and try again!"
		end
	end

	def getGeneralData
		val = params['val']
		general  = General.where(:item => "#{val}").last()
		content = general[:content]
		subject = general[:subject]
		respond_to do |format|
		    format.json { render json: {"content" => "#{content}", "subject" => "#{subject}"}}
		end
	end

	private
	    # Use callbacks to share common setup or constraints between actions.
	    def set_general
	      @general = General.find(params[:id])
	    end

	    # Never trust parameters from the scary internet, only allow the white list through.
	    def general_params
	      params.require(:general).permit(:type,
	                                        :subject,
	                                        :content)
	    end
end