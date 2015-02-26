module StripeInteractions
  extend ActiveSupport::Concern

  def charge_customer(user_id, total_in_cents, description)
    user = User.find(user_id)
    customer = Stripe::Customer.retrieve("#{user.stripe_customer_id}")

    begin

      charge = Stripe::Charge.create(
        :amount => total_in_cents,
        :currency => "usd",
        :customer => customer,
        :description => "#{description}"
      )

      self.stripe_charge_id = charge.id
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

  module ClassMethods
  end
end