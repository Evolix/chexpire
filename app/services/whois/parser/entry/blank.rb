require_relative "base"

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
