class PeopleTaxStatus < ActiveRecord::Base
  belongs_to :person
  belongs_to :tax_status
end
