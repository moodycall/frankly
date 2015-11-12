class PayoutsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_payout, only: [:show]
  respond_to :html

  # GET /counselors
  # GET /counselors.json
  def index
    if current_user.counselor.present?
      redirect_to payouts_counselor_url(current_user.counselor)
    else
      redirect_to root_path
    end
  end

  def show
    unless @payout.user.id == current_user.id
      if current_user.counselor.present?
        redirect_to payouts_counselor_url(current_user.counselor), notice: 'You can not access the counselor.'
      else
        redirect_to root_path, :notice => "You can not access the counselor."
      end
    else
      @page_title    = "Payout ##{@payout.secure_id}"
      respond_with(@payout)
    end
  end

  private
    def set_payout
      @payout = Payout.find(params[:id])
    end
end