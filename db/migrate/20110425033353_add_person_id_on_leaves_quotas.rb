class AddPersonIdOnLeavesQuotas < ActiveRecord::Migration
  def self.up
  	add_column :leaves_quotas, :person_id, :integer, :after => :company_id
	end

  def self.down
  	remove_column :leaves_quotas, :person_id
  end
end
