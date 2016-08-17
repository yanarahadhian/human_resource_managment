# == Schema Information
#
# Table name: health_details
#
#  id            :integer(4)      not null, primary key
#  health_id     :integer(4)
#  disease_name  :string(255)
#  start         :date
#  finish        :date
#  disease_efect :string(255)
#  reduction     :string(255)
#  description   :text
#  created_at    :datetime
#  updated_at    :datetime
#

class HealthDetail < ActiveRecord::Base
  belongs_to :healths
end

