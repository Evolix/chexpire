# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "null_logger"

namespace :checks do
  namespace :sync_dates do
    task all: [:domain, :ssl]

    def stdout_logger(env = {}) # rubocop:disable Metrics/MethodLength
      verbose_mode = env.fetch("VERBOSE") { 0 }.to_i == 1
      quiet_mode   = env.fetch("QUIET")   { 0 }.to_i == 1
      silent_mode  = env.fetch("SILENT")  { 0 }.to_i == 1

      if silent_mode
        NullLogger.new
      else
        logger = Logging.logger(STDOUT)
        logger.level = if quiet_mode
          :error
        elsif verbose_mode
          :debug
        else
          :info
        end

        logger
      end
    end

    desc "Refresh domains expiry dates"
    task domain: :environment do
      process = CheckDomainProcessor.new(
        logger: stdout_logger(ENV),
        configuration: Rails.configuration.chexpire.fetch("checks_domain"),
      )
      process.sync_dates
    end

    desc "Refresh SSL expiry dates"
    task ssl: :environment do
      process = CheckSSLProcessor.new(
        logger: stdout_logger(ENV),
        configuration: Rails.configuration.chexpire.fetch("checks_ssl"),
      )
      process.sync_dates
    end
  end
end
