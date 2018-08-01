# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

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

        def text?
          false
        end
      end
    end
  end
end
