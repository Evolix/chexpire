# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module SSL
  class Error < StandardError; end

  class SSLCommandError < Error; end
  class SSLConfigurationError < Error; end

  class ParserError < Error; end
  class DomainNotMatchError < ParserError; end
  class InvalidResponseError < ParserError; end
  class InvalidDateError < ParserError; end
end
