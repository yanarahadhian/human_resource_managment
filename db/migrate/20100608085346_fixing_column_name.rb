class FixingColumnName < ActiveRecord::Migration
  def self.up
    rename_column(:violations, :action_until, :active_until)
  end

  def self.down
    rename_column(:violations, :active_until, :action_until)
  end
end
