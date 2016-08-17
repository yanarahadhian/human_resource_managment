class EmploymentHistory < ActiveRecord::Base
  belongs_to :person
  belongs_to :company
  belongs_to :division
  belongs_to :position
end
