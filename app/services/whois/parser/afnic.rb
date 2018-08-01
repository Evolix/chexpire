# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "domain_helper"
require "whois/errors"
require_relative "base"

module Whois
  module Parser
    class AFNIC < Base
      SUPPORTED_TLD = %w[
        .fr
        .re
        .tf
        .yt
        .pm
        .wf
      ].freeze
      COMMENT_REGEX = /^%+ +(?<text>.+)$/
      FIELD_REGEX = /^(?<name>[^:]+)\s*:\s+(?<value>.+)$/

      def self.supports?(domain)
        SUPPORTED_TLD.include?(tld(domain))
      end

      protected

      def do_parse
        raise_not_found if comment_include?("No entries found")

        set_date_format

        extract_values
      end

      private

      def extract_values
        domain_index = get_field!("domain", value: domain).index

        created_date = get_value!("created", after: domain_index)
        response.created_at = parse_date(created_date)

        expire_date = get_value!("Expiry Date", after: domain_index)
        response.expire_at = parse_date(expire_date)

        updated_date = get_value!("last-update", after: domain_index)
        response.updated_at = parse_date(updated_date)
      end

      def parse_date(str)
        super "#{str} UTC"
      end

      def set_date_format
        afnic_format = get_field!("complete date format").value

        @date_format = "%d/%m/%Y %Z" if afnic_format == "DD/MM/YYYY"
      end
    end
  end
end
