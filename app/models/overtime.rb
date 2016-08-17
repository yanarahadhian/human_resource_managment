# == Schema Information
#
# Table name: overtimes
#
#  id                         :integer(4)      not null, primary key
#  company_id                 :integer(4)
#  person_id                  :integer(4)
#  start_overtime             :datetime
#  end_overtime               :datetime
#  overtime_length_in_minutes :integer(4)
#  overtime_status            :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  overtime_description       :string(255)
#  overtime_date              :date
#

class Overtime < ActiveRecord::Base
  belongs_to :person
  after_save :update_presence_report

  def self.who_take_overtime(company_id, start_date, end_date, options ={})
    people = Presence.people_filter(company_id, start_date, end_date, options)
    people_id = people.map{|p| p.id};
    overtimes = find(:all, :conditions => ["person_id IN (?) AND overtime_date BETWEEN ? AND ?", people_id, start_date, end_date], :order => 'overtime_date DESC')
    return overtimes
  end

  def self.summary_recap(company_id, start_date, end_date, options = {})
    people = Presence.people_filter(company_id, start_date, end_date, options)
    recap = []
    unless people.blank?
      people.each do |person|
        total_overtimes = person.overtimes.all(:conditions => ["overtime_date BETWEEN ? AND ?", start_date, end_date]).sum{ |o| o.overtime_length_in_minutes}
        if total_overtimes > 0
          compulsory_overtime = person.total_compulsory_overtimes(start_date, end_date)
          unaccounted_nc = PresenceReport.sum(:unaccounted_noncompulsory_overtime, :conditions => ['person_id = ? AND date BETWEEN ? AND ?', person.id, start_date, end_date])
          department = person.department(start_date)
          unless department
            department = person.department(end_date)
          end
            recap << {
              :person => person,
              :department => department,
              :compulsory_overtime => compulsory_overtime,
              :total_overtimes => total_overtimes,
              :nc_overtime => (total_overtimes - compulsory_overtime) + unaccounted_nc * 60
            }
        end
      end
    end
    return recap
  end

  def self.get_option_err(params)
    base_err = ""
    if params[:option] == "Pilih"
      base_err = "Pilih assign lembur"
    elsif params[:option] == "Group"
      # jika bagian/divisi dipilih
      if params[:divisions].first.to_i > 0
        base_err = "Pilih group dari karyawan" if params[:group].blank?
      else
        base_err= "Pilih bagian sebelum memilih group"
      end
    end
    return base_err
  end

  def self.get_person(params, company_id)
    the_people = Person.find(:all, :conditions => ['company_id = ? and latest_employment_id is not null', company_id])
    people = nil
    if params[:option] == "Personal"
    elsif params[:option] == "Karyawan"
      employees = params['employees'].to_a
      if !employees.blank? && (employees != [""])
        names = the_people.map { |x| "#{x.full_data_name}" }
        ids = the_people.map { |x| x.id }
        employee_ids = []
        employees.each do |employee|
          employee_ids << ids[names.index{|n| n == employee}] if !names.index{|n| n == employee}.nil?
        end
        people = Person.find(:all, :conditions=>{:id => employee_ids})
      end
    else
      groups = params['group'].to_a
      unless groups.blank?
        people = []
        groups.each do |g_id|
          workgroup = WorkGroup.find(g_id.to_i)
          people += workgroup.personel
        end unless groups.first.blank?
      end
    end
    return people
  end

  private
  def update_presence_report
    PresenceReport.update_report(self, 2)
  end

end


