class RemoveColumnFromEmployments < ActiveRecord::Migration
  def self.up
    remove_column :employments, :employee_identification
  end

  def self.down
    add_column :employments, :employee_identification, :string
  end
end
