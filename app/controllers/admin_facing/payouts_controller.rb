require 'admin_facing/admin_facing_controller.rb'
class AdminFacing::PayoutsController < AdminFacingController
  before_action :set_payout, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @payouts = Payout.where.not(:stripe_transfer_id => nil).order(:funds_sent_dts => :desc).all
    @tab_name = "index"
    @page_title    = "All Payouts"

    respond_to do |format|
      format.html
      format.csv { send_data @payouts.to_csv }
    end
  end

  def upcoming
    @payouts = Payout.where(:stripe_transfer_id => nil).all

    @tab_name = "upcoming"
    @page_title    = "Upcoming Payouts"

    respond_to do |format|
      format.html
      format.csv { send_data @payouts.to_csv }
    end
  end

  def bulk_transfer
    if params[:payout_ids].present?
      payouts = Payout.find(params[:payout_ids])
      payouts.each do |payout|
        if payout.total_in_cents != 0
          res = payout.transfer_funds(payout.total_in_cents)
          if res == "true"
            redirect_to :back, :notice => "Your Payout have successfully been issued."
          else
            redirect_to :back, :notice => "#{res}"
          end
        else
          redirect_to :back, :notice => "Payout for 0 amount can not be issued."
        end
      end
    else
      redirect_to :back, :notice => "Please select Payouts to Transfer."
    end
  end

  def show
    @page_title    = "Payout ##{@payout.secure_id}"
    respond_with(@payout)
  end

  def new
    @payout = Payout.new
    @page_title    = "New Payout"
    respond_with(@payout)
  end

  def edit
    @page_title    = "Edit Payout ##{@payout.secure_id}"
  end

  def create
    params[:payout][:total_in_cents] = params[:payout][:total_in_dollars].to_i * 100
    @payout = Payout.new(payout_params)
    @payout.save
    respond_with(@payout)
  end

  def update
    params[:payout][:total_in_cents] = params[:payout][:total_in_dollars].to_i * 100
    @payout.update(payout_params)
    respond_with(@payout)
  end

  def destroy
    @payout.destroy
    respond_with(@payout)
  end

  private
    def set_payout
      @payout = Payout.find(params[:id])
    end

    def payout_params
      params.require(:payout).permit(:user_id,
                                     :total_in_cents,
                                     :stripe_transfer_id)
    end
end
