class Feature < ActiveRecord::Base
  self.abstract_class = true
  if Rails.env.development?
    #establish_connection :users_core_development
  elsif Rails.env.production?
    #establish_connection :users_core_production
  end
  
  has_many :correlations
  belongs_to :action
  belongs_to :section
  
  validates_presence_of :name
end
