# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

ENV["RAILS_ENV"] ||= "test"
require "pry"

if !ENV["NO_COVERAGE"] && (ARGV.empty? || ARGV.include?("test/test_helper.rb"))
  require "simplecov"
  SimpleCov.start "rails" do
    add_group "Notifier", "app/services/notifier"
    add_group "Whois", "app/services/whois"
    add_group "SSL", "app/services/ssl"
    add_group "Services", "app/services"
    add_group "Policies", "app/policies"
  end
end

require_relative "../config/environment"
require "rails/test_help"

require "minitest/mock"
require_relative "test_mocks_helper"
require_relative "chexpire_assertions"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include Warden::Test::Helpers
  Warden.test_mode!

  # Add more helper methods to be used by all tests here...
  include ActiveJob::TestHelper
  include FactoryBot::Syntax::Methods
  include TestMocksHelper
  include ChexpireAssertions
end

# Disable Open4 real system calls
# require "open4"
# require "errors"
module Open4
  def popen4(*)
    fail SystemCommand::NotAllowedError,
      "Real Open4 calls are disabled in test env. Use mock_system_command helper instead."
  end
  alias open4 popen4
  alias pfork4 popen4
  alias popen4ext popen4

  module_function :open4
  module_function :popen4
  module_function :pfork4
  module_function :popen4ext
end
