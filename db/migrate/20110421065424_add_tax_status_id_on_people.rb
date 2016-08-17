class AddTaxStatusIdOnPeople < ActiveRecord::Migration
  def self.up
  	add_column :people, :tax_status_id, :integer
  end

  def self.down
  	remove_column :people, :tax_status_id
  end
end
