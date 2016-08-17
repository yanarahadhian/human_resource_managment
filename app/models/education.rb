# == Schema Information
#
# Table name: educations
#
#  id                         :integer(4)      not null, primary key
#  person_id                  :integer(4)
#  educational_institution_id :integer(4)
#  field_major                :string(255)
#  entry_year                 :integer(4)
#  graduation_year            :integer(4)
#  gpa                        :float
#  education_description      :text
#  created_at                 :datetime
#  updated_at                 :datetime
#  certificate_file_name      :string(255)
#  certificate_content_type   :string(255)
#  certificate_file_size      :integer(4)
#  pendidikan_terakhir        :string(255)
#  no_ijazah                  :string(255)
#  institution_name           :string(255)
#  company_id                 :integer(4)
#

class Education < ActiveRecord::Base
  
  belongs_to :person
  belongs_to :educational_institution
  has_attached_file :certificate

  validate :valid_year?
  validates_presence_of :pendidikan_terakhir, :message=> "Pendidikan terakhir tidak boleh kosong"
  validates_uniqueness_of :no_ijazah, :message=> "No Ijazah ini sudah terdaftar", :allow_blank=>true
  validates_numericality_of :gpa, :less_than_or_equal_to => 999.0, :message => "Nilai yang anda input masih salah", :allow_blank=>true
  validates_attachment_content_type :certificate, :content_type => ['image/jpeg', 'image/png'], :allow_blank=>true

   def self.params_to_date(education)
     education.update(:birth_date=> education[:birth_date].to_date) unless education[:birth_date].blank?
     return education
  end

  def valid_year?
    if !entry_year.blank? && !graduation_year.blank?
      unless (entry_year.to_s =~ /^(19|20)\d\d$/)
        errors.add(:entry_year, "is invalid")
      end      
      unless (graduation_year.to_s =~ /^(19|20)\d\d$/)
        errors.add(:graduation_year, "is invalid")
      end
      if (graduation_year < entry_year )
        errors.add(:entry_year, "is invalid")
        errors.add(:graduation_year, "is invalid")
      end
    end
  end
  
  
  def options
    {  :pendidikan_terakhir => ['SD', 'SLTP', 'SLTA', 'SMK', 'D1-D2', 'D3–D4', 'S1', 'S2', 'tidak sekolah']
    }
  end
end

