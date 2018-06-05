namespace :checks do
  desc "Refresh expiry dates for checks"
  task sync_dates: :environment do
    process = CheckProcessor.new
    process.sync_dates
  end
end
