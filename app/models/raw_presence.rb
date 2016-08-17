class RawPresence < ActiveRecord::Base
  validates_uniqueness_of :presence_time, :scope => :reg_id

  def self.fetch_raw_data
    devices = FingerprintDevice.all
    logfile = File.open("#{RAILS_ROOT}/log/scheduler.log", 'a')
    logfile.sync = true
    scheduler_log = Logger.new(logfile)
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Fetch data from Fingerprint Device Started"
    unless devices.blank?
      attend_records = []
      devices.each do |dev|
        time = Time.now
        scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Starting fetch data from device #{dev.ip_address} company #{dev.company_id}"
        attend_records = dev.read_device(time)
        unless attend_records.blank?
          if attend_records[0]["http_error"]
            scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Gagal membaca dari alat fingerprint #{dev.ip_address} #{attend_records[0]["error_detail"]}"
          elsif attend_records[0]["soap_fault"]
            scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Gagal membaca dari alat fingerprint #{dev.ip_address} #{attend_records[0]["error_detail"]}"
          else
            inserts = []
            attend_records.each do |att|
              finger_time = Time.parse(att["DateTime"]).utc
              finger_id = att["PIN"].to_i
              person = Person.find_by_fingerprint_user_and_company_id(finger_id, dev.company_id)
              unless person.blank?
                raw_presence = RawPresence.find(:last, :conditions => ['reg_id = ? AND presence_time = ? AND company_id = ?', finger_id, finger_time, dev.company_id ])
                inserts.push "(#{finger_id}, '#{finger_time.to_s(:db)}', #{att["Status"].to_i}, #{dev.company_id}, '#{Time.now.utc.to_s(:db)}')" if raw_presence.blank?
              end
            end
            unless inserts.blank?
              sql = "INSERT INTO raw_presences (`reg_id`, `presence_time`, `status`, `company_id`, `created_at`) VALUES #{inserts.join(", ")}"
              RawPresence.connection.execute sql
            end
            dev.last_download = time
            dev.save(false)
            scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Sukses membaca dari alat fingerprint #{dev.ip_address}"
          end
        else
          scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Belum ada data baru dari alat fingerprint #{dev.ip_address}"
        end
      end
      scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Fetch data from Fingerprint Device Ended"
      return true
    else
      scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Data alat fingerprint tidak ada"
      scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Fetch data from Fingerprint Device Ended"
      return false
    end
  end

  def self.fetch_raw_data_by_company_id(company_id)
    devices = FingerprintDevice.find_all_by_company_id(company_id)
    logfile = File.open("#{RAILS_ROOT}/log/scheduler.log", 'a')
    logfile.sync = true
    scheduler_log = Logger.new(logfile)
    scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Fetch data from Fingerprint Device Started"
    unless devices.blank?
      attend_records = []
      devices.each do |dev|
        time = Time.now
        scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Starting fetch data from device #{dev.ip_address} company #{dev.company_id}"
        attend_records = dev.read_device(time)
        unless attend_records.blank?
          if attend_records[0]["http_error"]
            scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Gagal membaca dari alat fingerprint #{dev.ip_address} #{attend_records[0]["error_detail"]}"
          elsif attend_records[0]["soap_fault"]
            scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Gagal membaca dari alat fingerprint #{dev.ip_address} #{attend_records[0]["error_detail"]}"
          else
            inserts = []
            attend_records.each do |att|
              finger_time = Time.parse(att["DateTime"]).utc
              unless finger_time < 5.days.ago
                finger_id = att["PIN"].to_i
                person = Person.find_by_fingerprint_user_and_company_id(finger_id, dev.company_id)
                unless person.blank?
                  raw_presence = RawPresence.find(:last, :conditions => ['reg_id = ? AND presence_time = ? AND company_id = ?', finger_id, finger_time, dev.company_id ])
                  inserts.push "(#{finger_id}, '#{finger_time.to_s(:db)}', #{att["Status"].to_i}, #{dev.company_id}, '#{Time.now.utc.to_s(:db)}')" if raw_presence.blank?
                end
              end
            end
            unless inserts.blank?
              sql = "INSERT INTO raw_presences (`reg_id`, `presence_time`, `status`, `company_id`, `created_at`) VALUES #{inserts.join(", ")}"
              RawPresence.connection.execute sql
            end
            dev.last_download = time
            dev.save(false)
            scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Sukses membaca dari alat fingerprint #{dev.ip_address}"
          end
        else
          scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Belum ada data baru dari alat fingerprint #{dev.ip_address}"
        end
      end
      scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Fetch data from Fingerprint Device Ended"
      return true
    else
      scheduler_log.debug "--- #{Time.now.strftime("%F %H:%M:%S")} Data alat fingerprint tidak ada"
      scheduler_log.debug "#{Time.now.strftime("%F %H:%M:%S")} Fetch data from Fingerprint Device Ended"
      return false
    end
  end

  def self.fetch_device_data(device)
    attend_records = device.read_device
    rv = false
    unless attend_records.blank?
      unless attend_records[0]["http_error"] || attend_records[0]["soap_fault"]
        inserts = []
        attend_records.each do |att|
          finger_time = Time.parse(att["DateTime"]).utc
          finger_id = att["PIN"].to_i
          person = Person.find_by_fingerprint_user_and_company_id(finger_id, device.company_id)
          unless person.blank?
            raw_presence = RawPresence.find(:last, :conditions => ['reg_id = ? AND presence_time = ? AND company_id = ?', finger_id, finger_time, device.company_id ])
            inserts.push "(#{finger_id}, '#{finger_time.to_s(:db)}', #{att["Status"].to_i}, #{device.company_id}, '#{Time.now.utc.to_s(:db)}')" if raw_presence.blank?
          end
        end
        unless inserts.blank?
          sql = "INSERT INTO raw_presences (`reg_id`, `presence_time`, `status`, `company_id`, `created_at`) VALUES #{inserts.join(", ")}"
          ActiveRecord::Base.connection.execute( "LOCK TABLES #{RawPresence.table_name} WRITE" )
          ActiveRecord::Base.transaction do
            ActiveRecord::Base.connection.execute sql
          end
          ActiveRecord::Base.connection.execute( "UNLOCK TABLES" )
        end
        rv = true
      end
    end
    rv
  end

  def self.destroy_raw_data
    ActiveRecord::Base.connection.execute("TRUNCATE raw_presences")
  end

end
