# == Schema Information
#
# Table name: salary_master_datas
#
#  id              :integer(4)      not null, primary key
#  employment_id   :integer(4)
#  basic_salary    :decimal(12, 2)
#  cooperation_cut :decimal(12, 2)
#  created_at      :datetime
#  updated_at      :datetime
#  company_id      :integer(4)
#

class SalaryMasterData < ActiveRecord::Base
  belongs_to :person#employment
  has_many :premium_master_datas, :dependent => :destroy

  has_many :salary_master_data_histories, :dependent => :destroy do
    def find_by_periode(valid_from, valid_to)

      # Dapatkan tanggal kurang dari valid_from untuk yang last dari tanggal awal periode
      conditions =  "valid_from <= '#{valid_from}'"
      data_first = last(:conditions => conditions, :order=> "valid_from asc")

      # Jika kurang dari tidak ketemu berarti ambil setelahnya yang awal 
      if data_first.blank?
        conditions =  "valid_from > '#{valid_from}'"
        data_first = first(:conditions => conditions, :order=> "valid_from asc")
      end

      #Diatas kita mendapatkan batas tanggal awal untuk periode awal dari database
      #Jika batas awal tidak ketemu makan datanya kosong
      #Sebaliknya jika ketemu maka kita cari batas akhir

      unless data_first.blank?
        #Definisikan query untuk batas awal
        conditions_from = "valid_from >= '#{data_first.valid_from.strftime("%Y-%m-%d")}'"

        #Dapatkan tanggal valid_to yang paling awal
        conditions = "valid_to >= '#{valid_to}'"
        data_last = first(:conditions => conditions, :order=> "valid_from asc")

        # jika valid to _ketemu berarti ambil valid from nya dan definisikan query batas akhir periode
        conditions_to = ""
        unless data_last.blank?
          conditions_to = "valid_from <= '#{data_last.valid_from.strftime("%Y-%m-%d")}'"
        end

        condition_data = conditions_from
        condition_data << " AND " + conditions_to unless conditions_to.blank?
        data = all(:conditions => condition_data)
        return data
      else
        return nil
      end


      

#       conditions = "'#{valid_from}' between valid_from and IF (valid_to IS NULL, '2099-01-01', valid_to)"
#       conditions << " OR '#{valid_to}' between valid_from and IF (valid_to IS NULL, '2099-01-01', valid_to)"
#       data = all(:conditions => conditions)
#       debugger
#       return data
    end
  end

  accepts_nested_attributes_for :premium_master_datas, :allow_destroy => true  
  attr_accessor :data_karyawan, :valid_from_prev, :basic_salary_prev

  validates_presence_of :valid_from, :message => "Tanggal berlaku tidak boleh kosong"
  validates_presence_of :basic_salary, :message => "Gaji pokok tidak boleh kosong"
#  validate :check_date, :on => :update
#
#  def check_date
#    if !valid_from_prev.blank? && !valid_from.blank?
#      if valid_from_prev < valid_from
#        errors.add(:valid_from, "Tanggal tidak boleh lebih kecil dari tanggal sebelumnya")
#      end
#    end
#  end

  #cari history yang terakhir
  #update last valid_to dengan valid_from yang baru
  def self.create_new_history(data_master_salary)
    data = data_master_salary.salary_master_data_histories(:order=> :valid_from ).last
    unless data.blank?
      if data.update_attributes(:valid_to => data_master_salary.valid_from-1)
        create_history(data_master_salary)
      end
    else
      create_history(data_master_salary)
    end
  end

  def self.find_and_make_sure_user_has_access(salary_master_id, current_company_id)
    if salary_master_id and current_company_id
      salary_master = SalaryMasterData.find(:last, :conditions => { :id => salary_master_id, :company_id => current_company_id})
    end
    salary_master
  end

  def self.create_history(data_master_salary)
     history = data_master_salary.attributes
     history.delete("id")
     history.update(:salary_master_data_id => data_master_salary.id)
     history.update(:valid_from => data_master_salary.valid_from)
     arr_premium = []
     data_master_salary.premium_master_datas.each do |x|
        history_premium = x.attributes
        history_premium.delete("id")
        history_premium.delete("salary_master_data_id")
        history_premium.delete("created_at")
        history_premium.delete("updated_at")
        arr_premium<< history_premium
     end
     history.update(:premium_master_data_histories_attributes => arr_premium)
     SalaryMasterDataHistory.create(history)     
   end

  def self.set_download_premium_data(premiums)
    val = 10000
    premi_data_gaji = []
    premiums.each do |x|
      val = val+20000
      premi_data_gaji << val
    end
    return premi_data_gaji
  end

  def self.rebuild_master_data(params)
    premi = []
    if params["premium_master_data"]
      params["premium_master_data"].each_key do |x|
        premi << {:id=> x, :value => params["premium_master_data"][x]}
      end
      params.delete("premium_master_data")
    end
    if params["new_premium_master_data"]
       params["new_premium_master_data"].each_key do |x|
         premi << {:id=> nil, :value => params["new_premium_master_data"]["#{x}"], :premiums_in_company_id=> x}
       end
      params.delete("new_premium_master_data")
    end
    params.update(:premium_master_datas_attributes => premi)
    return params
  end

  def self.search(params)
    f = params[:filter]
    d = params[:date]
    kond = ""
    unless f.blank? || d.blank?
      unless f[:name].blank?
        kond << " AND " unless kond.blank?
        kond << "CONCAT(TRIM(people.firstname),' ',TRIM(people.lastname)) like '%#{f[:name]}%'" unless f[:name].blank?
      end
    end
  end

  def self.date_split(p_date)
    a = ""
    unless p_date.blank?
      b = p_date.split("/")
      if b.count==3 && b[2].length==4 && (b[1].length==1 || b[1].length==2) && (b[0].length==1 || b[0].length==2)
        a = "#{self.format_tgl(b[2])}-#{self.format_tgl(b[1])}-#{b[0]}"
      end
    end
    return a
  end

  def self.format_tgl(tgl)
    if tgl.to_i < 10
      return "0#{tgl.to_i}"
    end
    return tgl
  end

  def self.check_data(current_company_id,holding_company_id,basic_salary,cooperation_cut)
    search = self.find_by_company_id(current_company_id)
    if search.blank?
      Person.find(:all,:conditions => ["company_id = ? and holding_company_id = ?",current_company_id,holding_company_id]).each do |d|
        data = self.new()
        data.basic_salary = basic_salary.rand
        data.cooperation_cut = cooperation_cut.rand
        data.company_id = current_company_id
        data.person_id = d.id
        data.valid_from = d.employments[0].employment_start
        data.save!
        history = SalaryMasterDataHistory.new()
        history.salary_master_data_id = data.id
        history.basic_salary = data.basic_salary
        history.cooperation_cut = data.cooperation_cut
        history.company_id = current_company_id
        history.person_id = d.id
        history.valid_from = d.employments[0].employment_start
        history.save!
        # require "pp"
        # pp data.errors.full_messages
      end
    end
  end

private

  def self.get_last_master_data_history(data_master_salary)
     history =  data_master_salary.salary_master_data_histories
     unless history.blank?
       return history.last
     else
       return nil
     end
  end
end

