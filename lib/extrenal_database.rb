class ExternalDatabase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :inventory_development
end

