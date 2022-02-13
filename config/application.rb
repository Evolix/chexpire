require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
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

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.time_zone = "Europe/Paris"

    config.generators do |g|
      g.assets false
    end

    unless Rails.root.join("config/chexpire.yml").readable?
      fail "Missing Chexpire configuration file.
            You have to create the config/chexpire.yml file and set at least the required values.
            Look at config/chexpire.defaults.yml and INSTALL.md for more information"
    end

    default_config = Rails.application.config_for(:"chexpire.defaults")
    custom_config = Rails.application.config_for(:chexpire)
    custom_config ||= ActiveSupport::OrderedOptions.new

    merged_config = Hashie::Mash.new(default_config.deep_merge(custom_config))

    config.chexpire = merged_config
  end
end
