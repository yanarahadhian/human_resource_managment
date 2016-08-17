class ChangeTypeAbsenceDateOnAbsences < ActiveRecord::Migration
  def self.up
    change_column :absences, :absence_date, :date
  end

  def self.down
    change_column :absences, :absence_date, :time
  end
end

