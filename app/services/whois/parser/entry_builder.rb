# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require_relative "entry/blank"
require_relative "entry/field"
require_relative "entry/text"

module Whois
  module Parser
    class EntryBuilder
      attr_reader :field_regex
      attr_reader :comment_regex

      def initialize(field_regex:, comment_regex:)
        @field_regex = field_regex
        @comment_regex = comment_regex
      end

      def build_from_line(line, index)
        text = normalize_text(line)

        return Entry::Blank.new(index) if line.empty?

        build(index, text).tap do |entry|
          entry.comment! if comment?(line)
        end
      end

      private

      def build(index, text)
        parts = field_regex.match(text)

        if parts.nil?
          Entry::Text.new(index, text)
        else
          Entry::Field.new(index, parts[:name], parts[:value])
        end
      end

      def normalize_text(line)
        line.strip!

        comment_data = comment_regex.match(line)

        if comment_data.nil?
          line
        else
          comment_data[:text]
        end
      end

      def comment?(line)
        comment_regex.match?(line)
      end
    end
  end
end
