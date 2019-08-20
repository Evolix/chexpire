# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

module Whois
  class NeustarTest < ActiveSupport::TestCase
    test "should parse a whois response for .us" do
      parser = Whois::Parser::Neustar.new("domain.us")
      whois_output = file_fixture("whois/domain.us.txt").read
      response = parser.parse(whois_output)
      assert_kind_of Whois::Response, response

      assert_equal Time.new(2002, 4, 18, 15, 36, 40, 0), response.created_at
      assert response.created_at.utc?

      assert_equal Time.new(2018, 6, 2, 0, 5, 41, 0), response.updated_at
      assert_equal Time.new(2019, 4, 17, 23, 59, 59, 0), response.expire_at
    end

    test "should raises DomainNotFoundError for .us when domain is not registered" do
      parser = Whois::Parser::Neustar.new("willneverexist.us")
      not_found = file_fixture("whois/willneverexist.us.txt").read

      assert_raises DomainNotFoundError do
        parser.parse(not_found)
      end
    end

    test "should raises InvalidDateError for .us when a date is not parsable" do
      parser = Whois::Parser::Neustar.new("domain.us")
      whois_output = file_fixture("whois/domain.us.txt").read
      whois_output.gsub!("2018-06-02T00:05:41Z", "not a date")

      assert_raises InvalidDateError do
        parser.parse(whois_output)
      end
    end
  end
end
