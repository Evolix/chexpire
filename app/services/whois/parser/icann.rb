# Copyright (C) 2022 Jérémy Lecour <jlecour@evolix.fr>, 2022 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module Whois
  module Parser
    class Icann < Base
      # https://www.icann.org/resources/pages/epp-status-codes-2014-06-16-en
      SUPPORTED_TLD = %w[
        .org
      ].freeze

      COMMENT_REGEX = /^(%|>)+ +(?<text>.+)$/
      FIELD_REGEX = /^(?<name>[^:]+)\s*:\s+(?<value>.+)$/

      def self.supports?(domain)
        SUPPORTED_TLD.include?(tld(domain))
      end

      protected

      def do_parse
        raise_not_found if text_include?("Domain not found.")

        extract_values
      end

      private

      def extract_values
        domain_index = get_field!("Domain Name", value: domain.downcase).index

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
