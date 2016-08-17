class AppWorker < BackgrounDRb::MetaWorker
  set_worker_name :app_worker

  def download_attendance(args = {})
    RawPresence.fetch_raw_data_by_company_id(args[:company_id])
    Presence.device_import_by_company_id(args[:company_id])
    download_data = DownloadDataLog.last(:conditions => {:company_id => args[:company_id], :end_time => nil})
    download_data.update_attribute('end_time', Time.now) if download_data.present?
  end
  
end