require "test_helper"
require "ssl/parser"
require "ssl/errors"

module SSL
  class ParserTest < ActiveSupport::TestCase
    test "should parse a SSL check response" do
      parser = Parser.new("ssl0.domain.org")
      domain = file_fixture("ssl/ssl0.domain.org.txt").read
      response = parser.parse(domain)
      assert_kind_of Response, response

      assert_equal Time.new(2028, 6, 10, 9, 14, 18, 0), response.expire_at
      assert response.expire_at.utc?
    end

    test "should parse a SSL check response in another format and convert it in UTC" do
      parser = Parser.new("ssl1.domain.org")
      domain = file_fixture("ssl/ssl1.domain.org.txt").read
      response = parser.parse(domain)
      assert_kind_of Response, response

      assert_equal Time.new(2022, 8, 6, 0, 57, 0, 0), response.expire_at
      assert response.expire_at.utc?
    end

    # test "should raises DomainNotMatchError when parsed text does not match the domain" do
    #   parser = Parser.new("anotherdomain.fr")
    #   output = file_fixture("ssl/ssl1.domain.org.txt").read
    #
    #   assert_raises DomainNotMatchError do
    #     parser.parse(output)
    #   end
    # end

    test "should accept responses for wildcard certificates" do
      parser = Parser.new("ssl1.domain.org")
      output = file_fixture("ssl/wildcard.domain.org.txt").read

      response = parser.parse(output)

      assert_equal Time.new(2028, 6, 10, 9, 14, 18, 0), response.expire_at
      assert response.expire_at.utc?

      parser = Parser.new("deep.ssl1.domain.org")
      output = file_fixture("ssl/wildcard.domain.org.txt").read

      response = parser.parse(output)

      assert_equal Time.new(2028, 6, 10, 9, 14, 18, 0), response.expire_at
    end

    test "should raises InvalidResponseError when check response is not matched" do
      parser = Parser.new("ssl100.invalid.org")
      output = file_fixture("ssl/ssl100.invalid.org.txt").read

      assert_raises InvalidResponseError do
        parser.parse(output)
      end
    end

    test "should raises InvalidDateError when a date is not in the expected format" do
      parser = Parser.new("ssl101.invalid.org")
      output = file_fixture("ssl/ssl101.invalid.org.txt").read

      assert_raises InvalidDateError do
        parser.parse(output)
      end
    end
  end
end
