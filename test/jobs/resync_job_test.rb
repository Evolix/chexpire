# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

require "test_helper"

class ReyncJobTest < ActiveJob::TestCase
  test "enqueue a whois sync job" do
    check = create(:check, :domain)

    assert_enqueued_with(job: WhoisSyncJob, args: [check.id]) do
      ResyncJob.perform_now(check.id)
    end
  end

  test "enqueue a ssl sync job" do
    check = create(:check, :ssl)

    assert_enqueued_with(job: SSLSyncJob, args: [check.id]) do
      ResyncJob.perform_now(check.id)
    end
  end

  test "re enqueued job 5 times when check was not found" do
    assert_enqueued_jobs 0

    perform_enqueued_jobs(only: ResyncJob) do
      assert_raise ActiveRecord::RecordNotFound do
        ResyncJob.perform_now(9999)
      end
    end

    assert_performed_jobs 5, only: ResyncJob
  end
end
