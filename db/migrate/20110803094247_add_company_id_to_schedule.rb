class AddCompanyIdToSchedule < ActiveRecord::Migration
  def self.up
    add_column :employee_shifts, :company_id, :integer
  end

  def self.down
    remove_column :employee_shifts, :company_id
  end
end

