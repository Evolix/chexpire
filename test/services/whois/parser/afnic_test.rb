require "test_helper"
require "whois/parser/afnic"
require "whois/response"
require "whois/errors"

module Whois
  class AFNICTest < ActiveSupport::TestCase
    test "should parse a whois response" do
      parser = Parser::AFNIC.new("domain.fr")
      domain_fr = file_fixture("whois/domain.fr.txt").read
      response = parser.parse(domain_fr)
      assert_kind_of Response, response

      assert_equal Time.new(2004, 2, 18, 0, 0, 0, 0), response.created_at
      assert response.created_at.utc?

      assert_equal Time.new(2017, 1, 28, 0, 0, 0, 0), response.updated_at
      assert_equal Time.new(2019, 2, 17, 0, 0, 0, 0), response.expire_at
    end

    test "should raises DomainNotFoundError when domain is not registered" do
      parser = Parser::AFNIC.new("willneverexist.fr")
      not_found_fr = file_fixture("whois/willneverexist.fr.txt").read

      assert_raises DomainNotFoundError do
        parser.parse(not_found_fr)
      end
    end

    test "should raises InvalidDateError when a date is not in the expected format" do
      parser = Parser::AFNIC.new("domain.fr")
      domain_fr = file_fixture("whois/domain.fr.txt").read
      domain_fr.gsub!("17/02/2019", "17-02-2019")

      assert_raises InvalidDateError do
        parser.parse(domain_fr)
      end
    end
  end
end
