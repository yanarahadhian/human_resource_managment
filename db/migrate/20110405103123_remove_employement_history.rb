class RemoveEmployementHistory < ActiveRecord::Migration
  def self.up
    drop_table :employment_histories
  end

  def self.down
    create_table :employment_type do |t|
      t.references :company
      t.string :employment_type_name
      t.string :tax_info
      t.timestamps
    end
  end
end
