class UpdateEmployeeTaxStatus < ActiveRecord::Migration
  def self.up
    company_ids = TaxStatus.all.collect(&:company_id).uniq.compact
    company_ids.each do |company_id|
      tax_id = TaxStatus.first(:conditions => {:company_id => company_id}).id - 1
      people = Person.all(:conditions => {:company_id => company_id})
      people.each do |person|
        if person.tax_status_id
          new_tax_status = person.tax_status_id.to_i % 8 == 0 ? 8 : person.tax_status_id.to_i % 8
          person.update_attributes(:tax_status_id => tax_id + new_tax_status )
        end
      end
    end
  end

  def self.down
  end
end
