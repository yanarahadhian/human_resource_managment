class CreateHrSetting < ActiveRecord::Migration
  def self.up
    create_table :hr_setting do |t|
      t.references :company
      t.integer :lateness_tolerance_in_minutes
      t.integer :period_in_minutes
      t.integer :leaves_first_year_quota
      t.integer :leaves_quota_per_year
      t.timestamps
    end
  end

  def self.down
    drop_table :hr_setting
  end
end
