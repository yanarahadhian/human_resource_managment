class CreateAbsenceQuotas < ActiveRecord::Migration
  def self.up
    create_table :absence_quotas do |t|
      t.integer :absence_type_id
      t.integer :company_id
      t.integer :quota
      t.boolean :replaceable
      t.timestamps
    end
  end

  def self.down
    drop_table :absence_quotas
  end
end
