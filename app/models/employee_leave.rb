# == Schema Information
#
# Table name: employee_leaves
#
#  id                :integer(4)      not null, primary key
#  company_id        :integer(4)
#  person_id         :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  leave_date        :date
#  leave_description :string(255)
#

class EmployeeLeave < ActiveRecord::Base
  belongs_to :person
  belongs_to :supervisor , :class_name => 'Person' , :foreign_key => 'supervisor_id'
  belongs_to :absence_type, :foreign_key => 'type_id'

  validates_uniqueness_of :leave_date, :scope => :person_id, :message => "Karyawan telah cuti di hari ini"
  validates_presence_of :leave_date, :message => "Periode awal dan akhir cuti harus diisi"
  validates_presence_of :person_id, :message => "Nama karyawan tidak boleh kosong"

  def self.leaves_save (company_id, person_id, leave_date, leave_description )
    leaves = EmployeeLeave.new(:company_id => company_id, :person_id => person_id, :leave_date => leave_date, :leave_description => leave_description)
    return leaves
  end

  def delete_data
    leaves_period = EmployeeLeave.find(:all, :conditions => ['person_id = ? AND created_at = ?', self.person_id, self.created_at])
    leaves_period.each do |l|
    Absence.delete_all(['absence_date = ? AND person_id = ?', l.leave_date, l.person_id])
    l.destroy!
    end
  end

  def create_absence(date,status)
    if self.leave_status == "Approved"
      person = self.person
      absence_type = AbsenceType.find_by_type_id_and_company_id(self.type_id,person.company_id)
      unless self.leave_date == date
        leave_date = date
      else
        leave_date = self.leave_date
      end
      absence = Absence.find(:first, :conditions => ['absence_date = ? AND person_id = ?', leave_date, self.person_id])
      unless absence
        absence = person.absences.new
        absence.company_id = person.company_id
      end
      absence.absence_type_id = absence_type.id
      absence.absence_date = self.leave_date
      absence.save!
    elsif status == "Approved"
      unless self.leave_date == date
        leave_date = date
      else
        leave_date = self.leave_date
      end
      Absence.delete_all(['absence_date = ? AND person_id = ?', leave_date, self.person_id])
    end
  end

end


