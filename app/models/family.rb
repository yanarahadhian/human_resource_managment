# == Schema Information
#
# Table name: families
#
#  id                     :integer(4)      not null, primary key
#  person_id              :integer(4)
#  relationship_to_person :string(255)
#  full_name              :string(255)
#  gender                 :string(255)
#  city_of_birth          :string(255)
#  birth_date             :date
#  current_job            :string(255)
#  highest_education      :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  live_together          :string(255)
#  company_id             :integer(4)
#

class Family < ActiveRecord::Base
  
  has_one :address, :as => :owner
  belongs_to :person
  accepts_nested_attributes_for :address, :allow_destroy => true

  def options
      {
       :gender => ['pria','wanita'],
       :highest_education => ['SD', 'SLTP', 'SLTA', 'SMK', 'D1-D2', 'D3-D4', 'S1', 'S2', 'tidak sekolah'],
       :relationship_to_person => ['Adik','Anak','Ayah', 'Ibu', 'Istri','Kakak','Suami', 'Lain']
    }
  end

  validates_presence_of :full_name, :message => "Nama tidak boleh kosong"
  validates_presence_of :gender, :message => "Jenis kelamin tidak boleh kosong"
  attr_accessor :hubungan_lain

  def self.params_to_date(family)
    unless family[:birth_date].blank?
     return family.update(:birth_date=> family[:birth_date])
    else
     return family
    end
  end
  
end

