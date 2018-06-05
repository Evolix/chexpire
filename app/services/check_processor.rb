class CheckProcessor
  attr_reader :configuration

  def initialize(configuration = nil)
    @configuration = configuration || default_configuration
  end

  def sync_dates # rubocop:disable Metrics/MethodLength
    %i[
      resolve_last_run_failed
      resolve_expire_short_term
      resolve_expire_long_term
      resolve_unknown_expiry
    ].each do |resolver|
      public_send(resolver).find_each(batch_size: 100).each do |check|
        process(check)

        sleep configuration.interval
      end
    end
  end

  def resolve_last_run_failed
    scope.last_run_failed
  end

  def resolve_expire_long_term
    scope
      .where("DATE(domain_expires_at) >= DATE_ADD(CURDATE(), INTERVAL ? DAY)",
            configuration.long_term)
      .where("DATEDIFF(domain_expires_at, CURDATE()) MOD ? = 0",
            configuration.long_term_frequency)
  end

  def resolve_expire_short_term
    scope.where("DATE(domain_expires_at) < DATE_ADD(CURDATE(), INTERVAL ? DAY)",
               configuration.long_term)
  end

  def resolve_unknown_expiry
    scope.where("domain_expires_at IS NULL")
  end

  private

  def scope
    Check
      .active
      .where("last_run_at IS NULL OR last_run_at < DATE_SUB(NOW(), INTERVAL 12 HOUR)")
  end

  def process(check)
    case check.kind.to_sym
    when :domain
      WhoisSyncJob.perform_now(check.id)
    else
      fail ArgumentError, "Unsupported check kind `#{check.kind}`"
    end
  end

  def default_configuration
    config = Rails.configuration.chexpire.fetch("checks", {})

    OpenStruct.new(
      interval: config.fetch("interval") { 0.00 },
      long_term: config.fetch("long_term") { 60 },
      long_term_frequency: config.fetch("long_term_frequency") { 10 },
    )
  end
end
