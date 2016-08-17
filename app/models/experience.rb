# == Schema Information
#
# Table name: experiences
#
#  id                    :integer(4)      not null, primary key
#  experience_type       :string(255)
#  person_id             :integer(4)
#  company_id            :integer(4)
#  division              :string(255)
#  position_held         :string(255)
#  job_description       :text
#  reason_of_termination :text
#  created_at            :datetime
#  updated_at            :datetime
#  no_telp               :string(255)
#  jenis_kerja           :string(255)
#  tema                  :string(255)
#  company_name          :string(255)
#  start_date            :integer(4)
#  end_date              :integer(4)
#  previous_company_id   :integer(4)
#

class Experience < ActiveRecord::Base
  
  belongs_to :person
  belongs_to :previous_company
#  attr_accessor :company_name

  validate :valid_year?
  validates_presence_of :start_date, :message => "Tahun masuk tidak boleh kosong"
  validates_presence_of :previous_company_id, :message => "Perusahaan tidak boleh kosong", :if => Proc.new { |experience|  experience.experience_type == 'work'}
  validates_presence_of :company_name, :message => "Perusahaan tidak boleh kosong", :if => Proc.new { |experience|  experience.experience_type == 'work'}
  validates_presence_of :company_name, :message => "Organisasi tidak boleh kosong", :if => Proc.new { |experience|  experience.experience_type == 'organizational'}
  validates_presence_of :end_date, :message => "Tahun keluar tidak boleh kosong", :if => Proc.new { |experience|  experience.experience_type != 'organizational'}

  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}"}}
  named_scope :by_experience_type, lambda {|val| {:conditions => "experience_type = '#{val}'"}}
  attr_accessor :data_type
  
#  def after_find
#    self.company_name = company.company_name
#  end
#
#  def before_save
#    self.company_id = Company.create(:company_name => company_name).id if company_id.blank?
#  end

  def valid_year?
    if (!start_date.blank? && !end_date.blank?)
      if (start_date > end_date)
        errors.add(:start_date, "is invalid")
        errors.add(:end_date, "is invalid")
      end
    end
  end
end

