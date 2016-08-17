# == Schema Information
#
# Table name: tax_statuses
#
#  id              :integer(4)      not null, primary key
#  tax_status_code :string(255)
#  ptkp            :decimal(12, 2)
#  created_at      :datetime
#  updated_at      :datetime
#

class TaxStatus < ActiveRecord::Base
	has_many :person
  has_one :people_tax_status

  attr_protected :company_id

  def self.initializer(companyid)
    tax_status = self.find(:all, :conditions => "company_id=#{companyid}")
    if tax_status.blank?
      data = [["T/0",1320000],["T/1",1430000],["T/2",1540000],["T/3",1650000],["K/0",1430000],["K/1",1540000],
              ["K/2",1650000],["K/3",1760000]]
      data.each do |x|
        tax_status = TaxStatus.new(:tax_status_code=> x[0], :ptkp=>x[1])
        tax_status.company_id = companyid
        tax_status.save
      end
    end
  end
end