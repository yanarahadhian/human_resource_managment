namespace :fix do
  desc "Fix download button every night with cronjob"
  task :absence => :environment do
    RawPresence.fetch_raw_data_by_company_id('3')
    Presence.device_import_by_company_id('3')
    download_data = DownloadDataLog.last(:conditions => {:company_id => '3', :end_time => nil})
    download_data.update_attribute('end_time', Time.now)
    File.open(RAILS_ROOT+"/log/absence.log", 'a') {|f|
      f.write("
Absence working at #{Time.now.to_s}
----------------------------------------------------------------------------------------------------------------------
        ")
    }
  end
end
namespace :absences do
  desc "Clear garbage data on presences and overtimes when absent"
  task :clear_data_absence => :environment do
    Absence.clear_other_data
    puts "Clear garbage data executed successfully!"
  end
end

namespace :presences do
  desc "Fetch raw data from fingerprint device"
  task :fetch_data => :environment do
    require 'savon'
    require 'httpi'
    require 'net/http'
    @company_id = CronUse.find(:first)
    RawPresence.fetch_raw_data_by_company_id(@company_id.company_id)
    # RawPresence.fetch_raw_data
  end

  desc "Clear Temporary raw_presences table"
  task :clear_data_raw => :environment do
    RawPresence.destroy_raw_data
    puts "Success clearing raw_presences"
  end

  desc "Moving data from raw_presences to presences table"
  task :moving_data => :environment do
    @company_id = CronUse.find(:first)
    Presence.device_import_by_company_id(@company_id.company_id)
    # Presence.device_import
  end
end

namespace :presence_report do
  desc "Insert/update presence_reports"
  task :insert_data => :environment do
    @company_id = CronUse.find(:first)
    PresenceReport.insert_presence_report_by_company_id(@company_id.company_id)
    # PresenceReport.insert_presence_report
  end

  desc "Clear presence_reports"
  task :clear_data => :environment do
    PresenceReport.destroy_raw_data
    puts "Success clearing presence_reports"
  end

  desc "Clear and repopulate presence_reports"
  task :reset => [:clear_data, :insert_data] do
    puts "Reset presence reports done!"
  end

  desc "Count overtimes on a week and update total overtimes"
  task :count_overtimes_this_week => :environment do
    @company_id = CronUse.find(:first)
    PresenceReport.count_overtimes_this_week_by_company_id(@company_id.company_id)
    # PresenceReport.count_overtimes_this_week
    puts "Count and update overtimes done!"
  end
end