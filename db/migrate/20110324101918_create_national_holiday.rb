class CreateNationalHoliday < ActiveRecord::Migration
  def self.up
    create_table :national_holiday do |t|
      t.references :company
      t.date :holiday_date
      t.string :holiday_name
      t.timestamps
    end
  end

  def self.down
    drop_table :national_holiday
  end
end
