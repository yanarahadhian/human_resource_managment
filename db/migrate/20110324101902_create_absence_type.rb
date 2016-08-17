class CreateAbsenceType < ActiveRecord::Migration
  def self.up
    create_table :absence_type do |t|
      t.reference :company
      t.string :absence_type_name
      t.boolean :is_salary_paid
      t.timestamps
    end
  end

  def self.down
    drop_table :absence_type
  end
end
