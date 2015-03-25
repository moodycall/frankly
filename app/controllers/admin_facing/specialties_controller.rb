require 'admin_facing/admin_facing_controller.rb'
class AdminFacing::SpecialtiesController < AdminFacingController
  before_action :set_specialty, only: [:show, :edit, :update, :destroy]

  # GET /specialties
  # GET /specialties.json
  def index
    @specialty = Specialty.new
    @specialties = Specialty.order(:is_active => :desc, :name => :asc).all

    @page_title    = "Specialties"
  end

  # GET /specialties/new
  def new
    @specialty = Specialty.new
    @page_title    = "New Specialty"
  end

  # GET /specialties/1/edit
  def edit
    @page_title    = "Edit #{@specialty.name}"
  end

  # POST /specialties
  # POST /specialties.json
  def create
    @specialty           = Specialty.new(specialty_params)
    @specialty.is_active = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[:specialty][:is_active])

    respond_to do |format|
      if @specialty.save
        format.html { redirect_to specialties_url, notice: 'Specialty was successfully created.' }
        format.json { render :show, status: :created, location: @specialty }
      else
        format.html { render :new }
        format.json { render json: @specialty.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /specialties/1
  # PATCH/PUT /specialties/1.json
  def update
    respond_to do |format|
      if @specialty.update(specialty_params)
        format.html { redirect_to specialties_url, notice: 'Specialty was successfully updated.' }
        format.json { render :show, status: :ok, location: @specialty }
      else
        format.html { render :edit }
        format.json { render json: @specialty.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /specialties/1
  # DELETE /specialties/1.json
  def destroy
    @specialty.destroy
    respond_to do |format|
      format.html { redirect_to specialties_url, notice: 'Specialty was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_specialty
      @specialty = Specialty.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def specialty_params
      params.require(:specialty).permit(:name, :is_active)
    end
end
