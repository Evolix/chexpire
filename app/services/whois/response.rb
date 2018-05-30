module Whois
  class Response
    attr_accessor :created_on
    attr_accessor :updated_on
    attr_accessor :expire_on

    def initialize(domain)
      @domain = domain
    end
  end
end
