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

      assert_equal Date.new(2004, 2, 18), response.created_on
      assert_equal Date.new(2017, 1, 28), response.updated_on
      assert_equal Date.new(2019, 2, 17), response.expire_on
    end
  end
end
