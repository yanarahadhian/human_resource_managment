class AddNewColumnOnPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :holding_company_id, :integer
    add_column :people, :employment_date, :date
    add_column :people, :employment_id, :string
  end

  def self.down
    remove_column :people, :holding_company_id
    remove_column :people, :employment_date
    remove_column :people, :employment_id
  end
end
