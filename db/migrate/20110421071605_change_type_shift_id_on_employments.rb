class ChangeTypeShiftIdOnEmployments < ActiveRecord::Migration
  def self.up
  	change_table :employments do |t|
  		t.change :shift_id, :integer
  	end
  end

  def self.down
  	change_table :employments do |t|
  		t.change :shift_id, :string
  	end
  end
end
