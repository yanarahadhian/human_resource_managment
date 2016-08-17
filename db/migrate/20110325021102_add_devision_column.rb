class AddDevisionColumn < ActiveRecord::Migration
  def self.up
    add_column :divisions, :company_id, :integer
    add_column :divisions, :department_id, :integer
    add_column :divisions, :division_code, :string
  end

  def self.down
    remove_column :divisions, :token_string
    remove_column :divisions, :department_id
    remove_column :divisions, :division_code
  end
end
