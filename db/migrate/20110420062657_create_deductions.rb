class CreateDeductions < ActiveRecord::Migration
  def self.up
    create_table :deductions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :deductions
  end
end
