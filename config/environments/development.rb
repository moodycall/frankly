Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.action_mailer.default_url_options = { host: 'lvh.me:3000' }
  config.session_store :cookie_store, key: '_moodycall_session', domain: ".lvh.me"

  config.action_mailer.delivery_method = :letter_opener

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  config.twilio_account_sid  = ENV["TWILIO_SID"]
  config.twilio_auth_token   = ENV["TWILIO_AUTH_TOKEN"]

  config.aws_access_key_id       = "AKIAJXY5CKQE5J4JLUQA"
  config.aws_secret_access_key   = "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"
  config.bucket_name             = "moody-dev"

  config.opentok_api_key         = "45162982"
  config.opentok_api_secret      = "3f87f912c00f0d01581509783c21c80ba57e91d0"
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
