require "domain_helper"
require_relative "base"

module Whois::Parser
  class Fr < Base
    SUPPORTED_TLD = %w[.fr].freeze
    COMMENT_REGEX = /^%+ +(?<text>.+)$/
    FIELD_REGEX = /^(?<name>[^:]+)\s*:\s+(?<value>.+)$/

    def self.supports?(domain)
      SUPPORTED_TLD.include?(tld(domain))
    end

    protected

    def do_parse
      set_date_format

      domain_index = get_field!("domain", value: domain).index

      created_date = get_value!("created", after: domain_index)
      response.created_at = parse_date(created_date)

      expire_date = get_value!("Expiry Date", after: domain_index)
      response.expire_at = parse_date(expire_date)

      updated_date = get_value!("last-update", after: domain_index)
      response.updated_at = parse_date(updated_date)
    end

    private

    def parse_date(str)
      super "#{str} UTC"
    end

    def set_date_format
      afnic_format = get_field!("complete date format").value

      @date_format = "%d/%m/%Y %Z" if afnic_format == "DD/MM/YYYY"
    end
  end
end
