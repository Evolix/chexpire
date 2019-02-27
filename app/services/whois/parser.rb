# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "null_logger"
require "whois/errors"
require "whois/parser/afilias"
require "whois/parser/afnic"
require "whois/parser/verisign"

module Whois
  module Parser
    PARSERS = [AFNIC, Verisign, Afilias].freeze

    class << self
      def for(domain, logger: NullLogger.new)
        parser_class = PARSERS.find { |k| k.supports?(domain) }

        fail UnsupportedDomainError, "Unsupported domain '#{domain}'" if parser_class.nil?

        parser_class.new(domain, logger: logger)
      end
    end
  end
end
