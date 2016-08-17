class AddInstitutionNameToEducation < ActiveRecord::Migration
  def self.up
    add_column :educations, :institution_name, :string
  end

  def self.down
    remove_column :educations, :institution_name
  end
end
