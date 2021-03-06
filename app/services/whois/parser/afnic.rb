# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module Whois
  module Parser
    class AFNIC < Base
      # https://www.afnic.fr
      # Rate limiting : 7200 requests per 24h
      # cf. https://www.afnic.fr/fr/ressources/documents-de-reference/documents-techniques/documents-techniques-supplementaires-1.html
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

        # Sometimes there is no "last-update" field, so we use the creation date
        updated_date = get_value("last-update", after: domain_index).presence || created_date
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
