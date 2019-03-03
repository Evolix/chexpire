# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"
# require "whois"
# require "system_command"

module Whois
  class ServiceTest < ActiveSupport::TestCase
    test "should run the command, return the result" do
      result = OpenStruct.new(exit_status: 0)

      mock_system_klass("whois", "example.org", result) do |system_klass|
        service = Service.new("example.org", system_klass: system_klass)
        assert_equal result, service.run_command
      end
    end

    test "should raise an exception if exit status > 0" do
      result = OpenStruct.new(exit_status: 1)

      mock_system_klass("whois", "example.org", result) do |system_klass|
        service = Service.new("example.org", system_klass: system_klass)

        assert_raises WhoisCommandError do
          service.run_command
        end
      end
    end

    test "should parse from a command result" do
      result = OpenStruct.new(
        exit_status: 0,
        stdout: file_fixture("whois/domain.fr.txt").read,
      )

      service = Service.new("domain.fr")
      assert_kind_of Response, service.parse(result)
    end

    def mock_system_klass(program, command_args, result)
      system_klass = Minitest::Mock.new
      system_command = Minitest::Mock.new.expect(:execute, result)
      system_klass.expect(:new, system_command) do |arg1, arg2, logger:|
        arg1 == program &&
          arg2 == command_args &&
          logger.class == NullLogger
      end

      yield system_klass

      system_klass.verify
      system_command.verify
    end
  end
end
