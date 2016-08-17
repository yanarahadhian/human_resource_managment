class Correlation < ActiveRecord::Base
  self.abstract_class = true
  if Rails.env.development?
    #establish_connection :users_core_development
  elsif Rails.env.production?
    #establish_connection :users_core_production
  end

  belongs_to :role
  belongs_to :feature
end
