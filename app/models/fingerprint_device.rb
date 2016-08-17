# == Schema Information
#
# Table name: fingerprint_devices
#
#  id            :integer(4)      not null, primary key
#  ip_address    :string(255)
#  port          :integer(4)
#  device_name   :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  company_id    :integer(4)
#  last_download :datetime
#

class FingerprintDevice < ActiveRecord::Base
  has_many :fingerprint_device_access_logs, :dependent => :delete_all
  validates_presence_of :device_name
  validates_presence_of :ip_address
  validates_uniqueness_of :ip_address, :scope => :company_id
  # validates_format_of :ip_address, :with => /\A(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)(?:\.(?:25[0-5]|(?:2[0-4]|1\d|[1-9])?\d)){3}\z/
  validates_format_of :ip_address, :with => /\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/, :message => "Masukkan IP Address seusai format"
  attr_protected :company_id

  require 'savon'
  require 'httpi'
  require 'net/http'

  after_save :set_fingerprint_device_on_hr_setting
  after_destroy :unset_fingerprint_device_on_hr_setting
  def set_fingerprint_device_on_hr_setting
    hr_setting = HrSetting.find_by_company_id(self.company_id)
    hr_setting.update_attributes(:fingerprint_device_is_set => true) if !hr_setting.blank? && !hr_setting.fingerprint_device_is_set
  end

  def unset_fingerprint_device_on_hr_setting
    device = FingerprintDevice.find(:first, :conditions=> "company_id = #{self.company_id}")
    hr_setting = HrSetting.find_by_company_id(self.company_id)
    hr_setting.update_attributes(:fingerprint_device_is_set => false) if !device.blank?
  end

  def update_fingerprint_device_on_hr_setting(company_id, is_set, is_connected)
    hr_setting = HrSetting.find_by_company_id(company_id)
    hr_setting.update_attributes(:fingerprint_device_is_set => is_set, :fingerprint_device_is_connected => is_connected) unless hr_setting.blank?
    FingerprintDevice.count_and_update_no_schedule_on_hr_setting(self.company_id)
  end

  def read_device(time_end = Time.now)
    request = "GetAttLog"
    xml_arg = '<GetAttLog><ArgComKey xsi:type="xsd:integer">0</ArgComKey><Arg><PIN xsi:type="xsd:integer">All</PIN></Arg></GetAttLog>'
    begin
      response = self.send_request(request, xml_arg)
      if response
        if response.http_error?
          FingerprintDeviceAccessLog.create(
            :status => false,
            :access_time => Time.now,
            :fingerprint_device_id => self.id,
            :description => response.http_error.to_s
          )
          update_fingerprint_device_on_hr_setting(self.company_id, false, false)
          return [{"http_error" => response.http_error.present?, "error_detail" => "Protocol Problem"}]
        elsif response.success?
          FingerprintDeviceAccessLog.create(
            :status => true,
            :access_time => Time.now,
            :fingerprint_device_id => self.id,
            :description => "Pembacaan data berhasil"
          )
          update_fingerprint_device_on_hr_setting(self.company_id, true, true)
          attendance_record = Hash.from_xml(response.to_xml)["GetAttLogResponse"]["Row"]
          unless attendance_record.blank?
            return attendance_record
          else
            return []
          end
        else
          FingerprintDeviceAccessLog.create(
            :status => false,
            :access_time => Time.now,
            :fingerprint_device_id => self.id,
            :description => response.soap_fault.to_s
          )
          update_fingerprint_device_on_hr_setting(self.company_id, false, false)
          return [{"soap_fault" => response.soap_fault.present?, "error_detail" => "SOAP Problem"}]
        end
      else
        FingerprintDeviceAccessLog.create(
          :status => false,
          :access_time => Time.now,
          :fingerprint_device_id => self.id,
          :description => "Network is unreachable"
        )
        update_fingerprint_device_on_hr_setting(self.company_id, false, false)
        return [{"http_error" => true, "error_detail" => "Network is unreachable" }]
      end
    rescue => e
      Rails.logger.info "#\n###### Unexpected Error When Get Data from Device! \nError Message: e.inspect "
      HoptoadNotifier.notify(e)
      nil
    end
  end

  def check_device
    request = "GetDate"
    xml_arg = '<GetDate><ArgComKey xsi:type="xsd:integer">0</ArgComKey></GetDate>'
    response = self.send_request(request, xml_arg)
    if response
      if response.http_error?
        rv = false
      elsif response.success?
        rv = true
      else
        rv = false
      end
    else
      rv = false
    end
    rv
  end

  def clear_data
    request = "ClearData"
    xml_arg = "<ClearData><ArgComKey xsi:type=\"xsd:integer\">0</ArgComKey><Arg><Value xsi:type=\"xsd:integer\">3</Value></Arg></ClearData>"
    response = self.send_request(request, xml_arg)
    if response
      if response.http_error?
        rv = false
      elsif response.success?
        record = Hash.from_xml(response.to_xml)["ClearDataResponse"]["Row"]
        rv = record["Result"].to_i == 1
      else
        rv = false
      end
    else
      rv = false
    end
    rv
  end

  def save_clear_data
    rv = false
    if RawPresence.fetch_device_data(self)
      #Presence.device_import
      rv = true if self.clear_data
    end
    rv
  end

  def send_request(request, xml_arg)
    HTTPI.adapter = :net_http
    host = self.ip_address
    if self.port.to_i > 0
      host = [host, "#{self.port}"].join(":")
    end
    client = Savon::Client.new do
      wsdl.endpoint = "http://#{host}/iWsService"
      wsdl.namespace = "http://#{host}/iWsService"
    end
    begin
      rv = client.request(request) { soap.xml = xml_arg }
    rescue
      rv = false
    end
    rv
  end

  def self.count_and_update_no_schedule_on_hr_setting(company_id)
    conditions = "people.id NOT IN (select person_id from employee_shifts where shift_from < '#{Date.today.to_s(:db)}' AND shift_to >= '#{Date.today.to_s(:db)}' AND company_id = #{company_id})AND company_id = #{company_id}"
    people = Person.count(:all, :select => 'id', :conditions => conditions)
    hr_setting = HrSetting.find_by_company_id(company_id)
    hr_setting.update_attributes(:no_schedule => people) unless hr_setting.blank? && hr_setting.no_schedule != people
  end

end


