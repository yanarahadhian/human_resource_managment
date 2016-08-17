# == Schema Information
#
# Table name: absence_quotas
#
#  id              :integer(4)      not null, primary key
#  absence_type_id :integer(4)
#  company_id      :integer(4)
#  quota           :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#  replaceable     :integer(4)
#


# TODO: Some kind of unused maybe save to delete
# By Nanto.
class AbsenceQuotas < ActiveRecord::Base
  validates_presence_of :quota , :message =>'Quota harus diisi'
  validates_numericality_of :quota , :message =>'Input harus angka'
end

