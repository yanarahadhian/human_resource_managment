# == Schema Information
#
# Table name: employment_types
#
#  id                   :integer(4)      not null, primary key
#  company_id           :integer(4)
#  employment_type_name :string(255)
#  tax_info             :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

class EmploymentType < ActiveRecord::Base
  belongs_to :company
  has_one :employment
  accepts_nested_attributes_for :employment, :allow_destroy => true
  def name_with_initial
      "#{employment_type_name}"
  end

  def self.check_data(company_id,type)
    search = self.find_by_company_id(company_id)
    if search.blank?
      puts "    Running employment type"
      type.each do |d|
        type = self.new()
        type.company_id = company_id
        type.employment_type_name = d
        type.save!
      end
    end
  end

end

