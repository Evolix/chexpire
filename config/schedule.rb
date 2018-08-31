# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, standard: "log/cron.log"

job_type :rake_with_stdout, "cd :path && :environment_variable=:environment bundle exec rake :task"

# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 1.day, at: '1:00 am', roles: [:app] do
  rake_with_stdout "checks:sync_dates:all QUIET=1"
end

every 1.day, at: '8:30 am', roles: [:app] do
  rake "notifications:send_all"
end
