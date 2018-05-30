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
