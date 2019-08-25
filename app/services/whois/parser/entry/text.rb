# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

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
