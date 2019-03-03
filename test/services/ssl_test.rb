# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"
require "ssl"
# require "system_command"

module SSL
  class ServiceTest < ActiveSupport::TestCase
    test "should run the command, return the result" do
      result = OpenStruct.new(exit_status: 0)

      mock_system_klass("check_http", standard_args, result) do |system_klass|
        service = Service.new("example.org", system_klass: system_klass)
        assert_equal result, service.run_command
      end
    end

    test "should raise an exception if exit status > 0" do
      result = OpenStruct.new(exit_status: 1)

      mock_system_klass("check_http", standard_args, result) do |system_klass|
        service = Service.new("example.org", system_klass: system_klass)

        assert_raises SSLCommandError do
          service.run_command
        end
      end
    end

    test "should parse from a command result" do
      result = OpenStruct.new(
        exit_status: 0,
        stdout: file_fixture("ssl/ssl0.domain.org.txt").read,
      )

      service = Service.new("ssl0.domain.org")
      assert_kind_of Whois::Response, service.parse(result)
    end

    test "should uses the command line arguments of the configuration" do
      result = OpenStruct.new(exit_status: 0)
      config = OpenStruct.new(check_http_args: ["-f", "-I 127.0.0.1"])

      expected_args = standard_args.concat ["-f", "-I 127.0.0.1"]
      mock_system_klass("check_http", expected_args, result) do |system_klass|
        service = Service.new("example.org", configuration: config, system_klass: system_klass)
        assert_equal result, service.run_command
      end
    end

    test "should raise an error when check_http_args is not an array" do
      black_hole = Naught.build(&:black_hole)
      config = OpenStruct.new(check_http_args: "-f")

      assert_raises SSLConfigurationError do
        service = Service.new("example.org", configuration: config, system_klass: black_hole)
        service.run_command
      end
    end

    test "should uses the program path from the configuration" do
      result = OpenStruct.new(exit_status: 0)
      config = OpenStruct.new(check_http_path: "/usr/local/custom/path")

      mock_system_klass("/usr/local/custom/path", standard_args, result) do |sys|
        service = Service.new("example.org", configuration: config, system_klass: sys)
        assert_equal result, service.run_command
      end
    end

    private

    def standard_args
      ["-C 0", "--sni", "-H", "example.org"]
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
