# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module Whois
  class Error < StandardError; end

  class WhoisCommandError < Error; end
  class UnsupportedDomainError < Error; end
  class DomainNotFoundError < Error; end
  class ParserError < Error; end

  class FieldNotFoundError < ParserError; end
  class InvalidDateError < ParserError; end
end
