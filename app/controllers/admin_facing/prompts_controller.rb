require 'admin_facing/admin_facing_controller.rb'
class AdminFacing::PromptsController < AdminFacingController
  before_action :set_prompt, only: [:show, :edit, :update, :destroy]

  # GET /prompts
  # GET /prompts.json
  def index
    @prompts     = Prompt.all
    @page_title  = "Prompts"
  end

  # GET /prompts/1
  # GET /prompts/1.json
  def show
    @upcoming_deliveries = @prompt.session_prompts.where(:sent_email_dts => nil, :sent_sms_dts => nil).all
    @page_title    = "Prompt ##{@prompt.secure_id}"
  end

  # GET /prompts/new
  def new
    @prompt = Prompt.new
    @page_title    = "New Prompt"
  end

  # GET /prompts/1/edit
  def edit
    @page_title    = "Edit Prompt ##{@prompt.secure_id}"
  end

  # POST /prompts
  # POST /prompts.json
  def create
    @prompt = Prompt.new(prompt_params)

    respond_to do |format|
      if @prompt.save
        format.html { redirect_to @prompt, notice: 'Prompt was successfully created.' }
        format.json { render :show, status: :created, location: @prompt }
      else
        format.html { render :new }
        format.json { render json: @prompt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /prompts/1
  # PATCH/PUT /prompts/1.json
  def update
    respond_to do |format|
      if @prompt.update(prompt_params)
        format.html { redirect_to @prompt, notice: 'Prompt was successfully updated.' }
        format.json { render :show, status: :ok, location: @prompt }
      else
        format.html { render :edit }
        format.json { render json: @prompt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prompts/1
  # DELETE /prompts/1.json
  def destroy
    @prompt.destroy
    respond_to do |format|
      format.html { redirect_to prompts_url, notice: 'Prompt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prompt
      @prompt = Prompt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def prompt_params
      params.require(:prompt).permit(:name,
                                     :quantity,
                                     :secure_id,
                                     :interval,
                                     :send_before_session,
                                     :enable_sms,
                                     :sms_message,
                                     :enable_email,
                                     :email_message,
                                     :audience_type,
                                     :is_active)
    end
end
