# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

module Notifier
  Configuration = Struct.new(:interval, :consecutive_failures)

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
      resolver.notifications_expiring_soon.find_each do |notification|
        notifier_channel_for(notification).notify(notification)

        sleep configuration.interval
      end
    end

    # Notify checks in error by email to the check owner adress email.
    # A single email contains all checks for a same user.
    def process_recurrent_failures
      failed_checks = resolver.checks_recurrent_failures(configuration.consecutive_failures)
      failed_checks.group_by(&:user).each_pair do |user, checks|
        channels[:email].notify_recurrent_failures(user, checks)

        sleep configuration.interval
      end
    end

    private

    def default_configuration
      Rails.configuration.chexpire.fetch("notifier")
    end

    def notifier_channel_for(notification)
      channels.fetch(notification.channel.to_sym)
    end
  end
end
