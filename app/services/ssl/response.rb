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
