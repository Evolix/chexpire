require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :headless_chrome

  def teardown
    Capybara.reset_sessions!
    Warden.test_reset!
  end
end
