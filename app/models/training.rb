# == Schema Information
#
# Table name: trainings
#
#  id                   :integer(4)      not null, primary key
#  person_id            :integer(4)
#  training_description :text
#  training_start       :date
#  training_end         :date
#  person_trained_as    :string(255)
#  person_trained_in    :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  training_type        :string(255)
#  promoter             :string(255)
#  promoter_address     :string(255)
#  promoter_phone       :string(255)
#  theme                :string(255)
#  certificate_number   :string(255)
#

class Training < ActiveRecord::Base
    
  belongs_to :person
 
  validates_presence_of :training_start, :message => "Tanggal mulai tidak boleh kosong"
  validates_presence_of :training_end, :message => "Tanggal selesai tidak boleh kosong"
  validates_presence_of :person_trained_in, :message => "Pelatih tidak boleh kosong"
  validate :valid_year?

  def options
    {
        :type => ['eksternal','internal']
     }
  end

  def valid_year?
    unless (training_start < training_end)
      errors.add(:training_start, "is invalid")
      errors.add(:training_end, "is invalid")
    end if !training_start.blank? && !training_end.blank?
  end

   def person_trained
    all_person = Person.all.map(&:full_name)
    if person_trained_in.downcase == person.full_name.downcase || !all_person.include?(person_trained_in)
       self.person_trained_in = nil
       errors.add(:person_trained_in, "can't be blank")
    end
  end

end
