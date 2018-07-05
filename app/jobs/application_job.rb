class ApplicationJob < ActiveJob::Base
  # from http://api.rubyonrails.org/classes/ActiveJob/Core.html
  attr_writer :attempt_number

  def attempt_number
    @attempt_number ||= 0
  end

  def serialize
    super.merge("attempt_number" => attempt_number + 1)
  end

  def deserialize(job_data)
    super
    self.attempt_number = job_data["attempt_number"]
  end

  rescue_from(Timeout::Error) do
    raise if attempt_number > 5 # rubocop:disable Style/SignalException
    retry_job(wait: 10)
  end
end
