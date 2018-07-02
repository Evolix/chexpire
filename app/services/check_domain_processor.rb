class CheckDomainProcessor
  include CheckProcessor
  protected

  def configuration_key
    "checks_domain"
  end

  def resolvers
    %i[
      resolve_last_run_failed
      resolve_expire_short_term
      resolve_expire_long_term
      resolve_unknown_expiry
    ]
  end

  def scope
    base_scope.domain
  end

  def process(check)
    WhoisSyncJob.perform_now(check.id)
  end
end
