# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

class NotifierTest < ActiveSupport::TestCase
  test "#process_all process expirable & failures notifications" do
    mock = Minitest::Mock.new
    mock.expect(:process_expires_soon, nil)
    mock.expect(:process_recurrent_failures, nil)

    myconfig = "test config"

    assert_stub = lambda { |actual_config|
      assert_equal myconfig, actual_config,
       "Processor was not initialized with the expected configuration"

      mock
    }

    Notifier::Processor.stub :new, assert_stub do
      Notifier.process_all(myconfig)
    end

    mock.verify
  end
end
