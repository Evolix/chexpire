require "test_helper"
require "whois/command"

module Whois
  class CommandTest < ActiveSupport::TestCase
    test "should return the result and log the command" do
      result = "mocked whois result"

      mock = Minitest::Mock.new
      mock.expect(:execute, result)

      stub = lambda do |program, args, _logger|
        assert_equal "whois", program
        assert_equal "example.org", args

        mock
      end

      SystemCommand.stub(:new, stub) do
        command = Command.new("example.org")
        assert_equal result, command.run
      end

      mock.verify
    end
  end
end
