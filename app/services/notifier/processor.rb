module Notifier
  Configuration = Struct.new(:interval, :failure_days)

  class Processor
    attr_reader :configuration
    attr_reader :channels
    attr_reader :resolver

    def initialize(configuration = nil)
      @configuration = configuration || default_configuration

      @resolver = Resolver.new
      @channels = {
        email: Channels::Email.new,
      }
    end

    def process_expires_soon
      resolver.resolve_expires_soon.find_each do |notification|
        notifier_channel_for(notification).notify(:expires_soon, notification)

        sleep configuration.interval
      end
    end

    def process_recurrent_failures
      resolver.resolve_check_failed.find_each do |notification|
        next unless should_notify_for_recurrent_failures?(notification)

        notifier_channel_for(notification).notify(:recurrent_failures, notification)

        sleep configuration.interval
      end
    end

    private

    def default_configuration
      config = Rails.configuration.chexpire.fetch("notifier", {})

      Configuration.new(
        config.fetch("interval") { 0.00 },
        config.fetch("failures_days") { 3 },
      )
    end

    def notifier_channel_for(notification)
      channels.fetch(notification.channel.to_sym)
    end

    def should_notify_for_recurrent_failures?(_notification)
      true
      # TODO: dependent of logs consecutive failures
    end
  end
end
