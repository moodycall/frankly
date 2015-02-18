CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                                       # required
    :aws_access_key_id      => Rails.configuration.aws_access_key_id,       # required
    :aws_secret_access_key  => Rails.configuration.aws_secret_access_key,   # required
    # :region                 => 'eu-west-1',                  # optional, defaults to 'us-east-1'
    # :host                   => 'dev-assets.breezeport.pw',             # optional, defaults to nil
    # :endpoint               => 'dev-assets.breezeport.pw', # optional, defaults to nil
    :path_style            => true
  }
  config.fog_directory  = Rails.configuration.bucket_name             # required
  # config.asset_host     = Rails.configuration.aws_asset_host
  # config.fog_public     = false                                   # optional, defaults to true
  # config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end
