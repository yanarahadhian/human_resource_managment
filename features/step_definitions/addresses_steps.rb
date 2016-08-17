Ketika /^saya mencentang "([^"]*)" pada alamat dengan id = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)  
  ids = Address.all(:conditions => "id=#{arg2}")
  @data = ids
end

Ketika /^saya menghapus alamat$/ do
  post addresses_delete_multiple_url(:ids=>@data,:person_id => @data.first.owner_id), :format => 'js'
  visit person_path(@data.first.owner_id)
end

Maka /^saya seharusnya memiliki (\d+) alamat berdasarkan person dengan employee_identification_number = "([^"]*)"?$/ do |num, nik|
  people = Person.find_by_employee_identification_number(nik)
  address = Address.all(:conditions => "owner_type ='person' AND owner_id=#{people.id}")
  address.count.should == num.to_i
end

When /^I delete address from ([^"]*)?$/ do |model|
  address = Address.find(:all, :conditions => "id in (#{@data.join(',')}) and owner_type='#{model}'")
  address_id = address.map{|x| x.id}
  owner_id = address.first.owner_id
  post addresses_delete_multiple_url(:ids=>address_id,:person_id => owner_id), :format => 'js'
  visit person_path(owner_id)
end