# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

namespace :notifications do
  desc "Send all notifications after checks have been performend"
  task send_all: :environment do
    Notifier.process_all
  end
end
