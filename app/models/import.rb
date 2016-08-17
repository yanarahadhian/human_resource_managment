# == Schema Information
#
# Table name: imports
#
#  id               :integer(4)      not null, primary key
#  datatype         :string(255)
#  processed        :integer(4)      default(0)
#  csv_file_name    :string(255)
#  csv_content_type :string(255)
#  csv_file_size    :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

class Import < ActiveRecord::Base
  require 'spreadsheet'
  has_attached_file :csv
  validates_attachment_content_type :csv, :content_type => ['application/excel','application/vnd.ms-excel','application/vnd.msexcel','text/plain'],
    :allow_blank=>true, :message => "Format upload harus application/excel"
  attr_accessor :company_id

  def import_to_db1
    sheet_path = self.csv.path
    book = Spreadsheet.open sheet_path    
    sheet = book.worksheet 0
    error = []    
    if (sheet.row(0)[0].strip.upcase=="NIK") && (sheet.row(0)[1].strip.upcase=="NAMA_LENGKAP") && (sheet.row(0)[2].strip.upcase=="JENIS_KELAMIN") && (sheet.row(0)[3].strip.upcase=="TEMPAT_LAHIR") &&
       (sheet.row(0)[4].strip.upcase=="TANGGAL_LAHIR") && (sheet.row(0)[5].strip.upcase=="AGAMA") && (sheet.row(0)[6].strip.upcase=="TANGGAL_DITERIMA") && (sheet.row(0)[7].strip.upcase=="DEPARTMENT") &&
       (sheet.row(0)[8].strip.upcase=="BAGIAN") && (sheet.row(0)[9].strip.upcase=="JABATAN") && (sheet.row(0)[10].strip.upcase=="NO_KTP") &&
       (sheet.row(0)[11].strip.upcase=="STATUS_PAJAK")      
      data = get_person_employment(sheet)
      data_person = data[:data_person]
      error = data[:error].compact
      if error.count == 0
        msg_suksess_or_error = create_person(data_person)
        return msg_suksess_or_error
      else
        return get_error(error)
      end
    else
      return "Data karyawan gagal diimport. silahkan download contoh format"
    end
  end
  
  #IMPORT ABSENT FROM EXCELL ===========================================================
  def import_presence_from_excell
    error_nik = ""
    error_nik_count = 0
    sheet_path = self.csv.path
    book = Spreadsheet.open sheet_path
    sheet = book.worksheet 0
    if (sheet.row(0)[0].strip.upcase=="NIK") && (sheet.row(0)[1].strip.upcase=="NAMA") && (sheet.row(0)[2].strip.upcase=="IN") && (sheet.row(0)[3].strip.upcase=="OUT") && (sheet.row(0)[4].strip.upcase=="DATE")
      data = get_data_absent(sheet) #konversi data excel menjadi data array
      for i in 1..(sheet.row_count-1)
        error_nik_count = import_presence(data,i) #memasukan data array ke dalam db presence dan presence_detail
        unless error_nik_count.blank?  or error_nik_count.nil?
          error_nik = error_nik + error_nik_count
        end
      end
      if error_nik.nil? or error_nik.blank?
        return "Import Data Absen Berhasil"
      else
        return "Import Data Absen Berhasil, namun ada NIK yang belum terdaftar yaitu = #{error_nik} "
      end    
    else
      return "Data Absen gagal diimport. silahkan download contoh format"
    end
  end
  
  def import_to_db2
    sheet_path = self.csv.path
    book = Spreadsheet.open sheet_path
    sheet = book.worksheet 0
    if (sheet.row(0)[0].strip.upcase=="NIK") && (sheet.row(0)[1].strip.upcase=="NAMA_DEPAN") && (sheet.row(0)[2].strip.upcase=="NAMA_BELAKANG") &&
       (sheet.row(0)[3].strip.upcase=="BERLAKU_MULAI") && (sheet.row(0)[4].strip.upcase=="GAJI_POKOK") && (sheet.row(0)[5].strip.upcase=="POTONGAN_KOPERASI")
      data = get_data_gaji(sheet)
      return prepare_create_gaji(data)
    else
      return "Data karyawan gagal diimport. silahkan download contoh format"
    end
  end

  def prepare_create_gaji(data)
    err = ""
    people_conditions = "#{Person.without_keluar_masuk} AND people.company_id=#{company_id}"
    people = Person.all(:include => [:employments],:conditions => people_conditions)    
    premium = Premium.all(:conditions => "company_id=#{company_id}")
    nik = []
    rs_set_data = {}
    premi_data =[]    
    data.each do |dt|      
      id_person = people.map {|x| x.employee_identification_number if x.employee_identification_number == dt[0].to_s.rstrip.lstrip}.compact
      # id_employement = people.map {|x| x.latest_employment_id.to_i if x.employee_identification_number == dt[0].to_s}.compact

      id_employment = people.map {|x| x.id if x.employee_identification_number == dt[0].to_s.rstrip.lstrip}.compact

      # jika person ada dalam database
      unless id_person.blank?
        # rs_set_data = {:employment_id => id_employement[0], :company_id => company_id}
          rs_set_data = {:person_id => id_employment[0], :company_id => company_id}        
        dt.each_with_index do |gaji, index|
          unless data[0][index].blank?
              id_premium = premium.map {|x| x.id.to_i if x.premium_name.downcase == data[0][index].downcase}.compact
              premi_data << {:premiums_in_company_id => id_premium[0], :value => gaji.to_i} unless id_premium.blank?
              rs_data = result_set_data(gaji, data[0][index])
              rs_set_data.update(rs_data) unless rs_data.blank?
          end
        end
        #create master data
        rs_set_data.update(:premium_master_datas_attributes => premi_data)
        err = create_gaji(rs_set_data)
        rs_set_data = {}
        premi_data =[]
      else
        nik << dt[0] unless dt[0] == "NIK"
      end      
    end
    if nik.compact.count > 0
      err += " Data karyawan gagal diimport untuk NIK #{nik.join(",")}, karena belum tersedia dalam database"
    end
    return err
  end

  def create_gaji(rs_set_data)
    err = ""
    salary_master_data = SalaryMasterData.first(:conditions => "person_id=#{rs_set_data[:person_id]} AND company_id=#{company_id}")

    # update jika data blank create jika masih kosong
    unless salary_master_data.blank?      
      rs_set_data[:premium_master_datas_attributes].each do |x|
        prem_mast_data = PremiumMasterData.find_by_salary_master_data_id_and_premiums_in_company_id(salary_master_data.id, x[:premiums_in_company_id])
        x.update(:id => prem_mast_data.id) unless prem_mast_data.blank?
      end      
      if salary_master_data.update_attributes(rs_set_data)
        SalaryMasterData.create_history(salary_master_data)
        err = "Master gaji berhasil diimport!"
      end
    else
      salary_master_data = SalaryMasterData.new(rs_set_data)
      if salary_master_data.save
        SalaryMasterData.create_history(salary_master_data)
        err = "Master gaji berhasil diimport!"
      end
    end
    return err
  end

  def result_set_data(gaji, col_name)
    if col_name.downcase == "gaji_pokok"      
      return :basic_salary => gaji.to_i
    end
    if col_name.downcase == "potongan_koperasi"
      return :cooperation_cut => gaji.to_i
    end
    if col_name.downcase == "berlaku_mulai"
      return :valid_from => gaji
    end
  end

  
  def get_data_gaji(sheet)
    data = []    
    for i in 0..(sheet.row_count-1)
      data[i] = []
      for j in 0 ..(sheet.column_count-1)
       if is_a_number?(sheet.row(i)[j])
         data[i][j] = sheet.row(i)[j].to_i
       else
         data[i][j] = sheet.row(i)[j]
       end
      end
    end
    return data
  end
 
 # BEGIN IMPORT PRESENCE FROM EXCELL ========================================================= 
  def get_data_absent(sheet)
    data = []
    for i in 1..(sheet.row_count-1)
      data[i] = []
      for j in 0 ..(sheet.column_count-1)
        if is_a_number?(sheet.row(i)[j])
          data[i][j] = sheet.row(i)[j].to_i
        else
          data[i][j] = sheet.row(i)[j]
        end
      end
    end
    return data
  end
  
  def import_presence(data,i)
    error_nik = ""
    unless data[i][0].blank?
      time_in = Time.parse(data[i][2])
      time_out = Time.parse(data[i+1][3])
      break_start = Time.parse(data[i][3])
      break_stop = Time.parse(data[i+1][2])
      presence_minute = 0
      minute_work_before_break= 0
      minute_work_after_break= 0
      minute_break = 0
      presence_hours = 0
      presence_paid = 0
      #count presence length in minute       
      presence_minute = count_longtime_in_minute(time_in,time_out)             
      #count work length in minute before break
      minute_work_before_break = count_longtime_in_minute(time_in,break_start)
      #count work length in minute after break
      minute_work_after_break = count_longtime_in_minute(break_stop,time_out)    
      #count break length in minute
      minute_break = count_longtime_in_minute(break_start,break_stop)
           
      presence_hours = (presence_minute.to_f/60).to_f
      presence_paid = presence_hours - (minute_break.to_f/60).to_f
      
      person = Person.find(:first, :conditions => { :employee_identification_number =>  data[i][0] } )  
      if person.nil?
        error_nik = "#{data[i][0]} "
      else             
        for j in 1..2
          presence = Presence.last(:conditions => ['person_id = ? AND presence_date = ?', person.id, data[i][4]] )   
          if presence.nil?
            Presence.new(
                          :company_id => company_id,
                          :person_id => person.id,
                          :presence_date => data[i][4], #DateTime.now.strftime("%Y-%m-%d"),  
                          :presence_length_in_hours => presence_hours,
                          :paid_hours => presence_paid,
                          :break_length_in_minutes => minute_break             
            ).save #==> memasukan ke dalam db presence
            present = Presence.last(:conditions => ['person_id = ?', person.id])
            present.presence_details.new(
                          :start_working => Time.parse("#{data[i][4]} #{data[i][2].to_s}").utc,
                          :end_working => Time.parse("#{data[i][4]} #{data[i][3].to_s}").utc,
                          :work_session_length_in_minutes => minute_work_before_break               
            ).save #==> memasukan ke dalam db presence_detail
          else
            cek_present = presence.presence_details.last(:conditions => ['start_working = ? AND end_working = ?', Time.parse("#{data[i][4]} #{data[i+1][2].to_s}").utc , Time.parse("#{data[i][4]} #{data[i+1][3].to_s}").utc ])
            if  cek_present.nil?
              present = Presence.last(:conditions => ['person_id = ?', person.id])
              present.presence_details.new(
                            :start_working => Time.parse("#{data[i][4]} #{data[i+1][2].to_s}").utc,
                            :end_working => Time.parse("#{data[i][4]} #{data[i+1][3].to_s}").utc,
                            :work_session_length_in_minutes => minute_work_after_break               
              ).save #==> memasukan ke dalam db presence_detail
            end  
          end
        end      
      end
            
    end 
    return error_nik  
  end
  
  def count_longtime_in_minute(start,stop)
    time_in_minute = 0
    if stop.min <= start.min
      time_in_minute = (((stop.hour-1) - start.hour) * 60) + (stop.min + 60 - start.min)
    else
      time_in_minute = ((stop.hour - start.hour) * 60) + (stop.min - start.min)
    end
    
    return time_in_minute   
  end

  def create_person(data_person)
    nik = []
    pjk = []
    is_err = false;
    is_save = false
    data_person.each do |p|
      #temp = p[:id]
      p[:id] = nil
      ob_person = Person.new(p)
      if ob_person.save
        ob_person.create_history_status_pajak
        is_save = true
        ob_person.update_attribute(:latest_employment_id, ob_person.employments.first.id)
      else
        is_err = true
        nik << "#{ob_person[:employee_identification_number]}"  unless ob_person.errors[:employee_identification_number].blank?
        pjk << "#{ob_person[:employee_identification_number]}"  unless ob_person.errors[:tax_status_id].blank?
      end
    end
    str_error = ""
    unless is_err
      str_error = "Data karyawan berhasil diimport."
    else
      if is_save
        str_error = "Data karyawan berhasil diimport. Tetapi "
      end
      str_error += "NIK (#{nik.join(", ")}) sudah digunakan. " unless nik.blank?
      str_error += "Pajak pada NIK (#{pjk.join(", ")}) didokument import tidak sesuai dengan data/kosong" unless pjk.blank?
    end
    return str_error
  end
  
  def get_data_people(sheet,i)
    name = Person.first_last_name(sheet.row(i)[1])
    nik = sheet.row(i)[0].blank? ? nil : sheet.row(i)[0]

    pjk_id = ""
    tax_status = TaxStatus.find(:first, :conditions => "tax_status_code='#{sheet.row(i)[11]}' AND company_id=#{company_id}")
    pjk_id = tax_status.id unless tax_status.blank?
    gender = sheet.row(i)[2].blank? ? "" : sheet.row(i)[2].downcase
    data = {
     :employee_identification_number => nik, 
     :employment_date => date_split(sheet.row(i)[6]),
     :firstname => name[:first_name],
     :lastname => name[:last_name],
     :gender => gender,
     :city_of_birth => sheet.row(i)[3],
     :birth_date => date_split(sheet.row(i)[4]),
     :religion => sheet.row(i)[5],
     :tax_status_id => pjk_id,
     :employments_attributes => [get_data_employment(sheet,i)]
    }
    data.update(:no_ktp => sheet.row(i)[10]) unless sheet.row(i)[10].blank?
    return data
  end

  def get_person_employment(sheet)
    data_person = []
    error = []
    nik= Person.all(:select=>"employee_identification_number").map {|x| x.employee_identification_number}
    nik = nik.compact
    for i in 1..(sheet.row_count-1)
      unless sheet.row(i)[1].blank?
       person = get_data_people(sheet,i).merge(:company_id => company_id)
       data_person << person
       get_error_column(person, error)
      end
    end
    return {:data_person => data_person,:error => error}
  end

  def get_error(error)
    str_error =""
    error.each do |x|
      str_error += "#{x}<br>" unless x.blank?
    end
    return str_error
  end

  def get_error_column(person, error)
    if person[:gender].downcase == "pria" || person[:gender].downcase == "wanita"
    else
      error[0] = "Jenis kelamin harus pria/wanita"
    end unless person[:gender].blank?
    error[1] = "Format Tanggal lahir adalah 'Tanggal/Tahun/Bulan' dalam numeric" if person[:birth_date].blank?
    error[2] = "Format tanggal diterima adalah 'Tanggal/Tahun/Bulan' dalam numeric" if person[:employment_date].blank?
    error[3] = cek_agama(person[:religion])
    return error
  end

  def cek_agama(religi)
    is_find = false
    Person.person_religion.each do |x|
      if x.downcase == religi.downcase
        is_find = true
      end
    end
    str_agama = "Agama masih salah" unless is_find
    return str_agama
  end


  
  def get_data_employment(sheet,i)
    department_id = get_department_id(sheet,i)
    division_id = get_bagian_id(sheet, i, department_id)
    return {:employment_start=> date_split(sheet.row(i)[6]),
     :department_id => department_id,
     :work_division_id => division_id,
     :position_id => get_jabatan_id(sheet, i),
     :change_from_before => "masuk kerja"
    }
  end

  def get_department_id(sheet,i)
    unless sheet.row(i)[7].blank?
      department = Department.find_by_department_name(sheet.row(i)[7])
      department = Department.create(:department_name => sheet.row(i)[7], :company_id => company_id) if department.blank?
      return department.id
    end
    return nil
  end

  def get_bagian_id(sheet, i, department_id)
    unless sheet.row(i)[8].blank?
      division = Division.find_by_name(sheet.row(i)[8])
      division = Division.create(:department_id => department_id, :name => sheet.row(i)[8], :company_id => company_id) if division.blank?
      return division.id
    end
    return nil
  end

  def get_jabatan_id(sheet, i)
    unless sheet.row(i)[9].blank?
      position = Position.find(:first, :conditions => ["position_name= ? AND company_id = ?", sheet.row(i)[9], company_id])
      if position.blank?
        position= Position.new(:position_name => sheet.row(i)[9])
        position.company_id = company_id 
        position.save
        return position.id
      end
    end
    return nil
  end

  def get_tax_status_id(code)    
    if code.blank?
      return nil
    else
      tax_status = TaxStatus.find_by_tax_status_code(code)
      tax_status = TaxStatus.create(:tax_status_code => code) if tax_status.blank?
      return tax_status.id
    end
  end

  def date_split(p_date)
    a = ""
    unless p_date.blank?
      b = p_date.split("/")
      if b.count==3 && b[2].length==4 && (b[1].length==1 || b[1].length==2) && (b[0].length==1 || b[0].length==2)
        a = "#{format_tgl(b[2])}-#{format_tgl(b[1])}-#{b[0]}"
      end
    end
    return a
  end

  def format_tgl(tgl)
    if tgl.to_i < 10
      return "0#{tgl.to_i}"
    end
    return tgl
  end

  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
  
end

