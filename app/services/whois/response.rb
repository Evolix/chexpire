module Whois
  class Response
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :expire_at

    def initialize(domain)
      @domain = domain
    end
  end
end
