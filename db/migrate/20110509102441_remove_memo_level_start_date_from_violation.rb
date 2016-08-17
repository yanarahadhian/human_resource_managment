class RemoveMemoLevelStartDateFromViolation < ActiveRecord::Migration
  def self.up
    remove_column :violations, :memo_level
    remove_column :violations, :start_date
  end

  def self.down
    add_column :violations, :memo_level, :string
    add_column :violations, :start_date, :date
  end
end
