class CreateEmploymentType < ActiveRecord::Migration
  def self.up
    create_table :employment_type do |t|
      t.references :company
      t.string :employment_type_name
      t.string :tax_info
      t.timestamps
    end
  end

  def self.down
    drop_table :employment_type
  end
end
