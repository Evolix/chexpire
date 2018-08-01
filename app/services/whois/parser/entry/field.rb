# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require_relative "base"

module Whois
  module Parser
    module Entry
      class Field < Base
        attr_reader :index
        attr_reader :name
        attr_reader :value

        def initialize(index, name, value)
          super index
          @name = name.strip
          @value = value.strip
        end

        def field?
          true
        end
      end
    end
  end
end
