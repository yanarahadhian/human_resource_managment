# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
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

set :job_template, nil
set :output, nil

every '20,50 * * * *' do
  rake "presences:fetch_data", :environment => "production"
end

every '30 0,4,8,10,12,14,16,20 * * *' do
  rake "presences:moving_data", :environment => "production"
end

every '0 1,5,9,11,13,15,17,21 * * *' do
  rake "presence_report:insert_data", :environment => "production"
end

every '30 9 * * 1' do
  rake "presence_report:count_overtimes_this_week", :environment => "production"
end
