module Notifier
  class << self
    def process_all(configuration = nil)
      processor = Processor.new(configuration)
      processor.process_expires_soon
      processor.process_recurrent_failures
    end
  end
end
