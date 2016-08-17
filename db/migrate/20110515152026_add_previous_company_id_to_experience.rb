class AddPreviousCompanyIdToExperience < ActiveRecord::Migration
  def self.up
    add_column :experiences, :previous_company_id, :integer
  end

  def self.down
    remove_column :experiences, :previous_company_id
  end
end
