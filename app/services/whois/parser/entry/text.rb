require_relative "base"

module Whois
  module Parser
    module Entry
      class Text < Base
        attr_reader :text

        def initialize(index, text)
          super index
          @text = text.strip
        end

        def text?
          true
        end
      end
    end
  end
end
