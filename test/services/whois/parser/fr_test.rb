require "test_helper"
require "whois/parser/fr"
require "whois/response"

module Whois
  class FrTest < ActiveSupport::TestCase
    setup do
      @parser = Parser::Fr.new("domain.fr")
      @domain_fr = file_fixture("whois/domain.fr.txt").read
    end

    test "should parse a whois response" do
      response = @parser.parse(@domain_fr)
      assert_kind_of Response, response

      assert_equal Time.new(2004, 2, 18, 0, 0, 0, 0), response.created_at
      assert response.created_at.utc?

      assert_equal Time.new(2017, 1, 28, 0, 0, 0, 0), response.updated_at
      assert_equal Time.new(2019, 2, 17, 0, 0, 0, 0), response.expire_at
    end
  end
end
