class CreateTaxStatuses < ActiveRecord::Migration
  def self.up
    create_table :tax_statuses do |t|
      t.string :tax_status_code
      t.decimal :ptkp, :precision => 12, :scale => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :tax_statuses
  end
end
