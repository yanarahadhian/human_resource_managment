class InsertDataToStatusPajak < ActiveRecord::Migration
  def self.up
    TaxStatus.create_or_update(:id => 1, :tax_status_code => 'T/0', :ptkp => 1320000)
    TaxStatus.create_or_update(:id => 2, :tax_status_code => 'T/1', :ptkp => 1430000)
    TaxStatus.create_or_update(:id => 3, :tax_status_code => 'T/2', :ptkp => 1540000)
    TaxStatus.create_or_update(:id => 4, :tax_status_code => 'T/3', :ptkp => 1650000)
    TaxStatus.create_or_update(:id => 5, :tax_status_code => 'K/0', :ptkp => 1430000)
    TaxStatus.create_or_update(:id => 6, :tax_status_code => 'K/1', :ptkp => 1540000)
    TaxStatus.create_or_update(:id => 7, :tax_status_code => 'K/2', :ptkp => 1650000)
    TaxStatus.create_or_update(:id => 8, :tax_status_code => 'K/3', :ptkp => 1760000)
  end

  def self.down
    TaxStatus.delete_all
  end
end

