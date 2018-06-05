require "null_logger"
require "whois/errors"
require "whois/parser/fr"
require "whois/parser/verisign"

module Whois
  module Parser
    PARSERS = [Fr, Verisign].freeze

    class << self
      def for(domain, logger: NullLogger.new)
        parser_class = PARSERS.find { |k| k.supports?(domain) }

        fail UnsupportedDomainError, "Unsupported domain '#{domain}'" if parser_class.nil?

        parser_class.new(domain, logger: logger)
      end
    end
  end
end
