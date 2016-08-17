# == Schema Information
#
# Table name: educational_institutions
#
#  id               :integer(4)      not null, primary key
#  institution_name :string(255)
#  institution_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  company_id       :integer(4)
#

class EducationalInstitution < ActiveRecord::Base
  has_many :educations
  has_many :addresses, :as => :owner
  accepts_nested_attributes_for :addresses
  
  validates_presence_of :institution_name, :institution_type
end

