class AddJamsostekCutByCompany < ActiveRecord::Migration
  def self.up
  	add_column :honors, :jamsostek_cut_by_company, :decimal, :precision => 12, :scale => 2
  end

  def self.down
  	remove_column :honors, :jamsostek_cut_by_company
  end
end