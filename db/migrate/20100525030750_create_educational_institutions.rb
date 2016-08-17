class CreateEducationalInstitutions < ActiveRecord::Migration
  def self.up
    create_table :educational_institutions do |t|
      t.string    :institution_name
      t.string    :institution_type
      t.timestamps
    end
  end

  def self.down
    drop_table :educational_institutions
  end
end
