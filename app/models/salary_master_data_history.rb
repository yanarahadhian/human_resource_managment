class SalaryMasterDataHistory < ActiveRecord::Base
  belongs_to :salary_master_data
  has_many :premium_master_data_histories, :dependent => :destroy
  accepts_nested_attributes_for :premium_master_data_histories, :allow_destroy => true
end
