class CreateEmployeeLeave < ActiveRecord::Migration
  def self.up
    create_table :employee_leave do |t|
      t.references :company
      t.references :person
      t.integer :quota_in_the_year
      t.integer :year
      t.date :redeem_date

      t.timestamps
    end
  end

  def self.down
    drop_table :employee_leave
  end
end
