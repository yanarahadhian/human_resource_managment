# == Schema Information
#
# Table name: overtime_datas
#
#  id             :integer(4)      not null, primary key
#  person_id      :integer(4)
#  division_id    :integer(4)
#  work_group_id  :integer(4)
#  start_overtime :time
#  reason         :string(255)
#  start_periode  :date
#  end_periode    :date
#  created_at     :datetime
#  updated_at     :datetime
#  status         :string(255)
#

class OvertimeData < ActiveRecord::Base
  belongs_to :person

  validates_presence_of :start_periode, :message => "Periode awal lembur tidak boleh kosong"
  validates_presence_of :end_periode, :message => "Periode akhir lembur tidak boleh kosong"
  validates_presence_of :person_id, :message => "Nama karyawan tidak boleh kosong"

  named_scope :by_company, lambda {|val| {:conditions => "overtime_datas.company_id = #{val}"}}

  def self.overtime_plan(company_id, start_date, end_date)
    people = []
    all_people = Person.all(:conditions => ["company_id = ?", company_id])
    all_people.each do |person|
      people << person if person.employment(end_date)
    end
    people_id = people.map{|p| p.id}
    overtimes = find(:all, :conditions => ["person_id IN (?) AND (? BETWEEN start_periode AND end_periode OR ? BETWEEN start_periode AND end_periode)", people_id, start_date, end_date], :order => 'start_periode DESC')
    return overtimes
  end

  def self.take_overtime_plan(company_id)
    overtimes = find(:all, :conditions => ["company_id = ? AND start_periode > ?", company_id, Date.today])
    people_id = overtimes.map{|o| o.person_id}.uniq
    people = Person.all(:conditions => {:id => people_id})
    return people
  end

  def self.search(f)
    kond = ""
    if (f[:filter_select]=="1")
      unless (f[:start_periode]).blank?
        kond << " AND" unless kond.blank?
        kond << " '#{Person.format_date(f[:start_periode])}' BETWEEN overtime_datas.start_periode AND overtime_datas.end_periode"
      end
    else
      if !(f[:start_periode]).blank? && !(f[:end_periode]).blank?
        kond << " AND" unless kond.blank?
        kond << " (overtime_datas.start_periode BETWEEN '#{Person.format_date(f[:start_periode])}' AND '#{Person.format_date(f[:end_periode])}') OR (overtime_datas.end_periode BETWEEN '#{Person.format_date(f[:start_periode])}' AND '#{Person.format_date(f[:end_periode])}') OR ('#{Person.format_date(f[:start_periode])}' BETWEEN overtime_datas.start_periode AND overtime_datas.end_periode) OR ('#{Person.format_date(f[:end_periode])}' BETWEEN overtime_datas.start_periode AND overtime_datas.end_periode)"
      elsif !(f[:start_periode]).blank? && (f[:end_periode]).blank?
        kond << " AND" unless kond.blank?
        kond << " overtime_datas.start_periode >= '#{Person.format_date(f[:start_periode])}'"
      elsif (f[:start_periode]).blank? && !(f[:end_periode]).blank?
        kond << " AND" unless kond.blank?
        kond << " overtime_datas.end_periode <= '#{Person.format_date(f[:end_periode])}'"
      end
    end
    return kond
  end
end

