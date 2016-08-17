class AddTypeEmploymentToEmployment < ActiveRecord::Migration
  def self.up
    add_column :employments, :type_employment, :string
  end

  def self.down
    remove_column :employments, :type_employment
  end
end
