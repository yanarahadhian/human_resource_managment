class Alter < ActiveRecord::Migration
  def self.up
     change_column :employee_leaves, :leave_description, :string
  end

  def self.down
     change_column :employee_leaves, :leave_description, :date
  end
end
