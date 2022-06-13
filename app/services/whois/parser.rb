# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module Whois
  module Parser
    PARSERS = [
      Afilias,
      AFNIC,
      CIRA,
      Icann,
      IO,
      Neustar,
      Sonic,
      Verisign,
    ].freeze

    class << self
      def for(domain, logger: NullLogger.new)
        parser_class = PARSERS.find { |k| k.supports?(domain) }

        fail UnsupportedDomainError, "Unsupported domain '#{domain}'" if parser_class.nil?

        parser_class.new(domain, logger: logger)
      end
    end
  end
end
