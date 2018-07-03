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
