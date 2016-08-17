class HoldingCompany < ActiveRecord::Base
  self.abstract_class = true
  if ($domain_sdm == '3006')
    #establish_connection :users_core_development
  elsif ($domain_sdm == '3004')
    #establish_connection :users_core_production
  end

  has_many :divisions
  has_many :people

  def self.check_data(company_id,holding_title)
    search = self.find_by_company_id(company_id)
    if search.blank?
      puts "    RUNNING HOLDING COMPANY "
      data = self.new({:title => holding_title,:company_id => company_id})
      data.save
    else
      data = search
    end
    return data.id
  end

end
