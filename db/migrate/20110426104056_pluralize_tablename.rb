class PluralizeTablename < ActiveRecord::Migration
  def self.up
    begin rename_table :work_unit, :work_units rescue true end
    begin rename_table :work_group, :work_groups rescue true end
    begin rename_table :department, :departments rescue true end
    begin rename_table :position, :positions rescue true end
  end

  def self.down
  end
end

