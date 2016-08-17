# == Schema Information
#
# Table name: work_contracts
#
#  id                        :integer(4)      not null, primary key
#  company_id                :integer(4)
#  person_id                 :integer(4)
#  contract_type_id          :integer(4)
#  contract_start            :date
#  contract_end              :date
#  created_at                :datetime
#  updated_at                :datetime
#  is_active_contract        :boolean(1)
#  previous_work_contract_id :integer(4)
#

class WorkContract < ActiveRecord::Base
  belongs_to :company
  belongs_to :person
  belongs_to :contract_type
  after_destroy :update_last_to_previous
  attr_accessor :contract_name

  named_scope :by_company, lambda {|val| {:conditions => "company_id = #{val}"}}
  
  def task_attributes=(task_attributes)
    task_attributes.each do |attributes|
      tasks.build(attributes)
    end
  end
  

  def update_last_to_previous
    person = Person.find_by_id(self.person_id)
    unless person.blank?
      if person.latest_work_contract_id == self.id
        person.update_attribute(:latest_work_contract_id, self.previous_work_contract_id)
      else
        work_contract = WorkContract.find_by_previous_work_contract_id(self.id)        
        work_contract.update_attribute(:previous_work_contract_id, self.previous_work_contract_id) unless work_contract.blank?
      end
    end
  end

  def self.get_chart_status(p_contract, company_id)
    contract_type = ContractType.by_company(company_id).all
    kontrak_name=[]
    kontrak_val = []
    contract_type.each do |y|
      pers_contract = p_contract.collect{|x| "#{x.person_id}" if x.contract_type_id == y.id}
      unless pers_contract.compact.uniq.count == 0
        kontrak_name << y.contract_type_name
        kontrak_val << pers_contract.compact.uniq.count
      end
    end
    return {:kontrak_name => kontrak_name, :kontrak_val => kontrak_val}
  end

  def self.set_percentage(value, tot)
    data = 0
    data = (value*100)/tot if value > 0
    data
  end
end
