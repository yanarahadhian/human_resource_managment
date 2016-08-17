class AddIsThrOnHonors < ActiveRecord::Migration
  def self.up
    add_column :honors, :is_thr, :boolean, :default => false
  end

  def self.down
    remove_column :honors, :is_thr
  end
end
