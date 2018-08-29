# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module CheckProcessor
  attr_reader :configuration

  def initialize(configuration = nil)
    @configuration = configuration || default_configuration
  end

  def sync_dates
    resolvers.each do |resolver|
      public_send(resolver).find_each(batch_size: 100).each do |check|
        process(check)

        sleep configuration.interval
      end
    end
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
      .auto
      .where("last_run_at IS NULL OR last_run_at < DATE_SUB(NOW(), INTERVAL 12 HOUR)")
  end

  # :nocov:
  def scope
    fail NotImplementedError, "#{self.class.name} did not implemented method #{__callee__}"
  end

  def process(_check)
    fail NotImplementedError, "#{self.class.name} did not implemented method #{__callee__}"
  end

  def configuration_key
    fail NotImplementedError, "#{self.class.name} did not implemented method #{__callee__}"
  end
  # :nocov:

  private

  def default_configuration
    Rails.configuration.chexpire.fetch(configuration_key)
  end
end
