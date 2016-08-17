class AddServiceStartEmploymentIdToEmployment < ActiveRecord::Migration
  def self.up
    add_column :employments, :service_start_employment_id, :integer
  end

  def self.down
    remove_column :employments, :service_start_employment_id
  end
end
