class RemoveServiceStartToEmployment < ActiveRecord::Migration
  def self.up
    remove_column :employments, :service_start_employment_id
  end

  def self.down
    add_column :employments, :service_start_employment_id, :integer
  end
end
