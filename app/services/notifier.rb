# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "notifier/processor"

module Notifier
  class << self
    def process_all(configuration = nil)
      processor = Processor.new(configuration)
      processor.process_expires_soon
      processor.process_recurrent_failures
    end
  end
end
