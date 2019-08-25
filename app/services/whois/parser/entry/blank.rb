# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module Whois
  module Parser
    module Entry
      class Blank < Base
        def blank?
          true
        end
      end
    end
  end
end
