class AddCompanyIdToOvertimeDatas < ActiveRecord::Migration
  def self.up
    add_column :overtime_datas, :company_id, :integer
  end

  def self.down
    remove_column :overtime_datas, :company_id
  end
end
