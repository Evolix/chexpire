require "null_logger"
require "system_command"

module Whois
  class Command
    attr_reader :logger
    attr_reader :domain

    def initialize(domain, logger: NullLogger.new)
      @domain = domain
      @logger = logger
    end

    def run
      SystemCommand.new("whois", domain, logger: logger).execute
    end
  end
end
