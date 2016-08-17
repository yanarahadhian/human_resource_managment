# == Schema Information
#
# Table name: contract_types
#
#  id                 :integer(4)      not null, primary key
#  company_id         :integer(4)
#  contract_type_name :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class ContractType < ActiveRecord::Base
  # belongs_to :company_id
  has_many :work_contracts
  
  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}"}}

   def self.check_data(company_id,person)
    search = self.find_by_company_id(company_id)
    if search.blank?
      puts "    7. Running Contract type"
      person[:contract_type].each do |ct|
        contract_type = ContractType.new()
        contract_type.company_id = company_id
        contract_type.contract_type_name = ct[0]
        contract_type.save!
      end
    end
  end
end

