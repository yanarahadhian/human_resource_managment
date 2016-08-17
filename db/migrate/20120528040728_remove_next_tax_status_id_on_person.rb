class RemoveNextTaxStatusIdOnPerson < ActiveRecord::Migration
  def self.up
  	remove_column :people, :next_tax_status_id
  end

  def self.down
  	add_column :people, :next_tax_status_id
  end
end