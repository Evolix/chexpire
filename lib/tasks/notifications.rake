# require "services/notifier"

namespace :notifications do
  desc "Send all notifications after checks have been performend"
  task send_all: :environment do
    Notifier.process_all
  end
end
