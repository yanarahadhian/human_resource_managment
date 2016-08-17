class CreatePayrollSettings < ActiveRecord::Migration
  def self.up
    create_table :payroll_settings do |t|
    	t.integer :company_id
    	t.string :full_working_days
      t.timestamps
    end
  end

  def self.down
    drop_table :payroll_settings
  end
end
