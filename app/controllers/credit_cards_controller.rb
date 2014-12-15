class CreditCardsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_credit_card, only: [:show, :edit, :update, :destroy]

  # GET /credit_cards
  # GET /credit_cards.json
  def index
    @credit_cards = current_user.credit_cards.all
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
    customer                    = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    card                        = customer.cards.create(:card => params[:stripeToken])
    @credit_card.stripe_card_id = card.id

    if @credit_card.save
      redirect_to credit_cards_path, notice: 'Credit card was successfully created.'
    else
      render :new
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
  def destroy
    @credit_card.is_active = false
    if @credit_card.save
      # If the account has been deactivated from MoodyCall,
      # we want to clear it from Stripe to prevent them from being billed.
      customer                    = Stripe::Customer.retrieve(current_user.stripe_customer_id)
      card                        = customer.cards.retrieve(@credit_card.stripe_card_id).delete()
    end

    respond_to do |format|
      format.html { redirect_to credit_cards_url, notice: 'Credit card was successfully destroyed.' }
      format.json { head :no_content }
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
