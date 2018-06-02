class WhoisSyncJob < ApplicationJob
  queue_as :default

  rescue_from ActiveRecord::RecordNotFound do; end

  attr_reader :check

  def perform(check_id)
    @check = Check.find(check_id)
    check.update_attribute(:last_run_at, Time.now)

    response = Whois.ask(check.domain)
    return unless response.valid?

    update_from_response(response)

    check.save!
  rescue Whois::DomainNotFoundError
    check.active = false
    check.save!
  rescue Whois::ParserError # rubocop:disable Lint/HandleExceptions
    # already logged
  end

  def update_from_response(response)
    check.domain_created_at = response.created_at
    check.domain_updated_at = response.updated_at
    check.domain_expire_at = response.expire_at
    check.last_success_at = Time.now
  end
end
