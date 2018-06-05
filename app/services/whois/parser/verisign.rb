require "domain_helper"
require "whois/errors"
require_relative "base"

module Whois
  module Parser
    class Verisign < Base
      SUPPORTED_TLD = %w[
        .com
        .net
        .cc
        .tv
        .name
        .jobs
        .edu
        .gov
      ].freeze
      COMMENT_REGEX = /^(%|>)+ +(?<text>.+)$/
      FIELD_REGEX = /^(?<name>[^:]+)\s*:\s+(?<value>.+)$/

      def self.supports?(domain)
        SUPPORTED_TLD.include?(tld(domain))
      end

      protected

      def do_parse
        raise_not_found if text_include?("No match for domain")

        extract_values
      end

      private

      def extract_values
        domain_index = get_field!("Domain Name", value: domain.upcase).index

        created_date = get_value!("Creation Date", after: domain_index)
        response.created_at = parse_date(created_date)

        expire_date = get_value!("Registry Expiry Date", after: domain_index)
        response.expire_at = parse_date(expire_date)

        updated_date = get_value!("Updated Date", after: domain_index)
        response.updated_at = parse_date(updated_date)
      end
    end
  end
end
