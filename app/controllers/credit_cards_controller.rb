class CreditCardsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_credit_card, only: [:show, :edit, :update, :deactivate]

  # GET /credit_cards
  # GET /credit_cards.json
  def index
    @credit_cards = current_user.credit_cards.where(:is_active => true).all
  end

  # GET /credit_cards/new
  def new
    @credit_card = current_user.credit_cards.new
  end

  # POST /credit_cards
  # POST /credit_cards.json
  def create
    @credit_card = current_user.credit_cards.new(credit_card_params)

    # We want to retrieve the customer from Stripe
    # Then add the new card to the customer
    begin
      customer                    = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      card                        = customer.cards.create(:card => params[:stripeToken])
    rescue Stripe::CardError => e
      # Since it's a decline, Stripe::CardError will be caught
      body = e.json_body
      err  = body[:error][:message]
      render :new, notice: "#{err}"
    else

      @credit_card.stripe_card_id = card.id
      @credit_card.last_four      = card.last4

      if @credit_card.save
        unless session[:pending_session_counselor_id].present?
          redirect_to user_dashboard_path, notice: 'Credit card was successfully created.'
        else
          redirect_to new_counseling_session_path, notice: 'You are almost done. Now you can finalize your session.'
        end
      else
        render :new
      end
    end
  end

  # PATCH/PUT /credit_cards/1
  # PATCH/PUT /credit_cards/1.json
  def update
    respond_to do |format|
      if @credit_card.update(credit_card_params)
        format.html { redirect_to @credit_card, notice: 'Credit card was successfully updated.' }
        format.json { render :show, status: :ok, location: @credit_card }
      else
        format.html { render :edit }
        format.json { render json: @credit_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /credit_cards/1
  # DELETE /credit_cards/1.json
  def deactivate
    @credit_card.is_active = false

    if @credit_card.save
      current_user.upcoming_sessions.each do |counseling_session|
        counseling_session.cancelled_on_dts = Time.now
        if counseling_session.save
          CounselorMailer.client_cancellation(counseling_session.id).deliver
          UserMailer.counseling_session_cancellation(counseling_session.id).deliver
        end
      end
      # If the account has been deactivated from MoodyCall,
      # uncomment below if we decide we need to remove from Stripe
      # customer                    = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      # card                        = customer.cards.retrieve(@credit_card.stripe_card_id).delete()
      redirect_to credit_cards_url, notice: 'Credit card was successfully destroyed and all upcoming session were cancelled.'
    else
      redirect_to credit_cards_url, notice: 'Credit card was not successfully.'
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_credit_card
      @credit_card = CreditCard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def credit_card_params
      params.require(:credit_card).permit(:user_id, :name, :stripe_card_id)
    end
end
