Rails.configuration.stripe = {
  :publishable_key => "pk_test_E0zSFId2UQvPIozfMjD863F7",
  :secret_key      => "sk_test_sbqNyhAVPZ9OHjHWhrvd3PdS"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
