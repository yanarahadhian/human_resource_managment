class DownloadJob < Struct.new(:company_id)
  def perform
    RawPresence.fetch_raw_data_by_company_id(company_id)
    Presence.device_import_by_company_id(company_id)
    PresenceReport.insert_presence_report_by_company_id(company_id)
    PresenceReport.count_overtimes_this_week_by_company_id(company_id)
    data_id = DownloadDataLog.all(:conditions => {:company_id => company_id, :end_time => nil})
    data_id.first.update_attribute('end_time', Time.now)
  end
end