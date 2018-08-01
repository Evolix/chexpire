# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module Whois
  class Response
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :expire_at

    def initialize(domain)
      @domain = domain
    end

    def valid?
      created_at.present?
    end
  end
end
