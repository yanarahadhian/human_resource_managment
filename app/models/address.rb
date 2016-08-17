# == Schema Information
#
# Table name: addresses
#
#  id         :integer(4)      not null, primary key
#  street1    :string(255)
#  street2    :string(255)
#  city       :string(255)
#  state      :string(255)
#  owner_id   :integer(4)
#  owner_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#  rt         :string(255)
#  rw         :string(255)
#  kecamatan  :string(255)
#  kelurahan  :string(255)
#  kode_pos   :string(255)
#  no_telp    :string(255)
#  company_id :integer(4)
#

class Address < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true
  
  validates_presence_of :street1, :message => "Jalan tidak boleh kosong"
  validates_presence_of :city, :message => "Kota tidak boloh kosong", :unless => Proc.new { |address| address.owner_type == "Family"}
  validates_presence_of :state, :message => "Propinsi tidak boloh kosong", :unless => Proc.new { |address| address.owner_type == "Family"}
  validates_numericality_of :no_telp, :message => "No telp harus numerik", :unless => Proc.new { |address| address.no_telp.blank? }
  validates_numericality_of :kode_pos, :unless => Proc.new { |address| address.kode_pos.blank? }
  validates_numericality_of :rt, :message => "RT harus numeric", :unless => Proc.new { |address| address.rt.blank? }
  validates_numericality_of :rw, :message => "RW harus numeric", :unless => Proc.new { |address| address.rw.blank? }
  
  def options
  {
    :address_type => ['rumah', 'kantor cabang', 'kantor pusat', 'etc']
  }
  end

  def self.last_person_address(p)
    str_alamat = ""
    unless p.addresses.blank?
      a = p.addresses.last
      str_alamat = a.last_address_to_str
    end
    return str_alamat
  end

  def last_address_to_str
    arr_alamat = []
    arr_alamat << "JL #{self.street1}" unless self.street1.blank?
    arr_alamat << "RT #{self.rt}" unless self.rt.blank?
    arr_alamat << "RW #{self.rw}" unless self.rw.blank?
    arr_alamat << "Kecamatan #{self.kecamatan}" unless self.kecamatan.blank?
    arr_alamat << "Keluarahan #{self.kelurahan}" unless self.kelurahan.blank?
    arr_alamat << "Keluarahan #{self.kelurahan}" unless self.kelurahan.blank?
    arr_alamat << "Kota #{self.city}" unless self.city.blank?
    arr_alamat << "Propinsi #{self.state}" unless self.state.blank?
    arr_alamat << "Kode Pos #{self.kode_pos}" unless self.kode_pos.blank?
    arr_alamat.join(",")
  end
end
