# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module SSL
  class Response
    attr_accessor :expire_at

    def initialize(domain)
      @domain = domain
    end

    def valid?
      expire_at.present?
    end
  end
end
