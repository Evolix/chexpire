# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

namespace :checks do
  namespace :sync_dates do
    task all: [:domain, :ssl]

    desc "Refresh domains expiry dates"
    task domain: :environment do
      logger = Logging.logger(STDOUT)
      logger.level = :warn
      configuration = Rails.configuration.chexpire.fetch("checks_domain")

      process = CheckDomainProcessor.new(logger: logger, configuration: configuration)
      process.sync_dates
    end

    desc "Refresh SSL expiry dates"
    task ssl: :environment do
      logger = Logging.logger(STDOUT)
      logger.level = :warn
      configuration = Rails.configuration.chexpire.fetch("checks_ssl")

      process = CheckSSLProcessor.new(logger: logger, configuration: configuration)
      process.sync_dates
    end
  end
end
