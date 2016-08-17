class AddColumnShiftOption < ActiveRecord::Migration
  def self.up
    add_column :employments, :shift_option_id, :integer
    add_column :employments, :shift_option_type, :string
  end

  def self.down
    remove_column :employments, :shift_option_id
    remove_column :employments, :shift_option_type
  end
end
