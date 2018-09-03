# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module CheckProcessor
  attr_reader :configuration, :logger

  def initialize(configuration:, logger: NullLogger.new)
    # Levels: debug info warn error fatal
    @logger = logger
    @configuration = configuration
  end

  def sync_dates # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    sync_started_at = Time.now
    logger.info "#{self.class.name}: sync_dates has started"

    resolvers.each do |resolver|
      logger.info "#{self.class.name}: using resolver '#{resolver}'"

      public_send(resolver).find_in_batches(batch_size: 100) do |checks|
        group_started_at = Time.now

        checks.each do |check|
          logger.info "#{self.class.name}: processing check ##{check.id}"
          process(check)

          logger.debug "#{self.class.name}: sleeping #{configuration.interval} seconds"
          sleep configuration.interval
        end

        group_finished_at = Time.now
        check_ids = checks.map(&:id)
        check_logs = check_errors_scope(check_ids: check_ids,
                                        after_date: group_started_at,
                                        before_date: group_finished_at).includes(:check).all

        message = "#{self.class.name}: #{check_logs.count} error(s) found for checks '#{check_ids.join(',')}' between '#{group_started_at}' and '#{group_finished_at}'" # rubocop:disable Metrics/LineLength
        logger.debug(message)

        check_logs.each do |check_log|
          message = "#{self.class.name}: check ##{check_log.check_id} for '#{check_log.check.domain}' failed (#{check_log.exit_status}) ; #{check_log.error.lines.first}" # rubocop:disable Metrics/LineLength
          logger.error(message)
        end
      end
    end

    sync_finished_at = Time.now
    duration = (sync_finished_at - sync_started_at).to_i
    logger.info "#{self.class.name}: sync_dates has finished (#{duration}s)"
  end

  def check_errors_scope(check_ids:, before_date: nil, after_date: nil)
    scope = CheckLog.failed.where("exit_status > 0").where(id: check_ids)
    scope = scope.where("created_at <= ?", before_date) if before_date
    scope = scope.where("created_at >= ?", after_date) if after_date

    scope
  end

  # :nocov:
  def resolvers
    fail NotImplementedError, "#{self.class.name} did not implemented method #{__callee__}"
  end
  # :nocov:

  def resolve_last_run_failed
    scope.last_run_failed
  end

  def resolve_expire_long_term
    scope
      .where("DATE(domain_expires_at) >= DATE_ADD(CURDATE(), INTERVAL ? DAY)",
            configuration.long_term_interval)
      .where("DATEDIFF(domain_expires_at, CURDATE()) MOD ? = 0",
            configuration.long_term_frequency)
  end

  def resolve_expire_short_term
    scope.where("DATE(domain_expires_at) < DATE_ADD(CURDATE(), INTERVAL ? DAY)",
               configuration.long_term_interval)
  end

  def resolve_unknown_expiry
    scope.where("domain_expires_at IS NULL")
  end

  def resolve_all
    scope
  end

  protected

  def base_scope
    Check
      .active
      .where("last_run_at IS NULL OR last_run_at < DATE_SUB(NOW(), INTERVAL 12 HOUR)")
  end

  # :nocov:
  def scope
    fail NotImplementedError, "#{self.class.name} did not implemented method #{__callee__}"
  end

  def process(_check)
    fail NotImplementedError, "#{self.class.name} did not implemented method #{__callee__}"
  end
  # :nocov:
end
