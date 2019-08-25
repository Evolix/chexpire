require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Chexpire
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.generators do |g|
      g.assets false
    end

    config.time_zone = "Europe/Paris"

    unless Rails.root.join("config", "chexpire.yml").readable?
      fail "Missing Chexpire configuration file.
            You have to create the config/chexpire.yml file and set at least the required values.
            Look at config/chexpire.defaults.yml and INSTALL.md for more information"
    end

    config.chexpire = Hashie::Mash.new(config_for(:"chexpire.defaults").deep_merge(config_for(:chexpire)))
  end
end

### Uncomment this to have zeitwerk debug log printed in stdout.
# Rails.autoloaders.logger = method(:puts)
