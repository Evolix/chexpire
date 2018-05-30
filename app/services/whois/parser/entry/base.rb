module Whois
  module Parser
    module Entry
      class Base
        attr_reader :index

        def initialize(index)
          @index = index
          @comment = false
        end

        def comment!
          @comment = true
        end

        def comment?
          @comment == true
        end

        def blank?
          false
        end

        def field?
          false
        end
      end
    end
  end
end
