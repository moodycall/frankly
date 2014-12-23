# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += [ Proc.new { |path, fn| fn =~ /app\/themes/ && !%w(.js .css).include?(File.extname(path)) } ]
Rails.application.config.assets.precompile += Dir["app/themes/*"].map { |path| "#{path.split('/').last}/all.js" }
Rails.application.config.assets.precompile += Dir["app/themes/*"].map { |path| "#{path.split('/').last}/all.css" }

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
