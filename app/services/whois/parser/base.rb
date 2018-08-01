# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "null_logger"
require_relative "../response"
require_relative "../errors"
require_relative "entry_builder"

module Whois
  module Parser
    class Base
      extend DomainHelper

      attr_reader :domain
      attr_reader :logger
      attr_reader :response
      attr_reader :entries
      attr_reader :date_format

      def initialize(domain, logger: NullLogger.new)
        @domain = domain
        @logger = logger
        @response = Response.new(domain)
        @date_format = nil
      end

      def parse(raw)
        @entries = build_entries(raw)

        do_parse

        logger.log :parsed_response, response

        response
      rescue ParserError => ex
        logger.log :parser_error, ex
        raise
      end

      protected

      def get_field!(name, after: -1, value: nil)
        fields.detect { |field|
          field.index > after &&
            field.name == name &&
            (value.nil? || field.value == value)
        } || fail(FieldNotFoundError, "Field `#{name}` not found, after index #{after}")
      end

      def get_value!(name, after: -1)
        get_field!(name, after: after).value
      end

      def parse_date(str)
        date_format.nil? ? Time.parse(str) : Time.strptime(str, date_format)
      rescue ArgumentError
        msg = if date_format.nil?
          "Date `#{str}` is not parsable without specifying a date format"
        else
          "Date `#{str}` does not match format #{date_format}"
        end

        raise InvalidDateError, msg
      end

      def comment_include?(str)
        entries.any? { |e|
          e.comment? && e.text? && e.text.include?(str)
        }
      end

      def text_include?(str)
        entries.any? { |e|
          e.text? && e.text.include?(str)
        }
      end

      def raise_not_found
        fail DomainNotFoundError, "Domain #{domain} not found in the registry database."
      end

      private

      def build_entries(raw)
        builder = EntryBuilder.new(
          field_regex: self.class::FIELD_REGEX,
          comment_regex: self.class::COMMENT_REGEX,
        )

        raw.split("\n").map.each_with_index { |line, index|
          builder.build_from_line(line, index)
        }.sort_by(&:index)
      end

      def fields
        @fields ||= entries.select(&:field?)
      end
    end
  end
end
