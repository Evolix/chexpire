class ResyncJob < ApplicationJob
  queue_as :default

  rescue_from ActiveRecord::RecordNotFound do
    raise if attempt_number == 5 # rubocop:disable Style/SignalException

    # at job creation, the db could not return immediately the check
    # we have to wait a few (milli)-seconds
    retry_job(wait: attempt_number**2)
  end

  def perform(check_id)
    check = Check.find(check_id)

    WhoisSyncJob.perform_later(check_id) if check.domain?
    SSLSyncJob.perform_later(check_id) if check.ssl?
  end
end
