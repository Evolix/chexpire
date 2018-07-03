class SSLSyncJob < ApplicationJob
  queue_as :default

  rescue_from StandardError do |exception|
    check_logger.log(:standard_error, exception) if check.present?
    raise # rubocop:disable Style/SignalException
  end

  rescue_from ActiveRecord::RecordNotFound do; end

  # parser error are already logged
  rescue_from SSL::Error do; end

  attr_reader :check

  def perform(check_id)
    prepare_check(check_id)

    response = SSL.ask(check.domain, logger: check_logger)
    return unless response.valid?

    update_from_response(response)
  end

  def update_from_response(response)
    check.domain_expires_at = response.expire_at
    check.last_success_at = Time.now

    check.save!
  end

  private

  def prepare_check(check_id)
    @check = Check.find(check_id)
    check.update_attribute(:last_run_at, Time.now)
  end

  # logger is a reserved ActiveJob method
  def check_logger
    @check_logger ||= CheckLogger.new(check)
  end
end
