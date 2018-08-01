# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class CheckSSLProcessor
  include CheckProcessor

  protected

  def configuration_key
    "checks_ssl"
  end

  def resolvers
    %i[
      resolve_all
    ]
  end

  def scope
    base_scope.ssl
  end

  def process(check)
    SSLSyncJob.perform_now(check.id)
  end
end
