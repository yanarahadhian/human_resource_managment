class AddMemoLevelStartDateToViolations < ActiveRecord::Migration
  def self.up
    add_column :violations, :memo_level, :string
    add_column :violations, :start_date, :date
  end

  def self.down
    remove_column :violations, :memo_level
    remove_column :violations, :start_date
  end
end
