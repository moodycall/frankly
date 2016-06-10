module StripeInteractions
  extend ActiveSupport::Concern

  def charge_customer(user_id, total_in_cents, description)
    user = User.find(user_id)
    if !user.stripe_customer_id.nil?
      customer = Stripe::Customer.retrieve("#{user.stripe_customer_id}")

      begin

        charge = Stripe::Charge.create(
          :amount => total_in_cents,
          :currency => "usd",
          :customer => customer,
          :description => "#{description}"
        )

        self.stripe_charge_id              = charge.id
        self.stripe_balance_transaction_id = charge.balance_transaction
        self.save

      rescue Stripe::CardError
        # Send error if no card if on file :: Cannot charge a customer that has no active card
        unless user.sent_initial_cc_request_dts.present?
          UserMailer.provide_cc_info(user_id).deliver
          user.sent_initial_cc_request_dts = Time.now
          user.save
        end
      end
    end
  end

  def update_transaction_total(balance_transaction_id)
    transaction = Stripe::BalanceTransaction.retrieve("#{balance_transaction_id}")
    self.stripe_processing_fee_in_cents = transaction.fee

    self.save
  end

  def transfer_funds(total_in_cents)
    # Create a transfer to the specified recipient
    begin

      transfer = Stripe::Transfer.create(
        :amount => total_in_cents, # amount in cents
        :currency => "usd",
        :destination => self.user.stripe_recipient_id,
        :description => "Payout from MoodyCall | #{self.id}"
      )
    rescue Stripe::StripeError => e
      # Since it's a decline, Stripe::CardError will be caught
      body = e.json_body
      err  = body[:error][:message]
    else

      self.stripe_transfer_id = transfer.id
      self.funds_sent_dts     = Time.now
      self.save
      res = "true"
    end
  end

  def issue_refund
    charge = Stripe::Charge.retrieve(self.stripe_charge_id)

    refund = charge.refunds.create

    self.stripe_refund_id = refund.id
    self.save
  end

  module ClassMethods
  end
end