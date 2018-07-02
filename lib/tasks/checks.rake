namespace :checks do
  namespace :sync_dates do
    task all: [:domain]

    desc "Refresh domains expiry dates"
    task domain: :environment do
      process = CheckDomainProcessor.new
      process.sync_dates
    end
  end
end
