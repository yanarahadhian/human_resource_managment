Ketika /^saya mencentang "([^"]*)" pada keluarga dengan id = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)
  ids = Family.all(:conditions => "id=#{arg2}")
  @data = ids
end

Ketika /^saya menghapus keluarga$/ do
 post families_delete_multiple_url(:ids=>@data,:person_id => @data.first.person_id), :format => 'js'
 visit person_path(@data.first.person_id)
end

When /^I delete family?$/ do
 family = Family.find(:all, :conditions => "id in (#{@data.join(',')})")
 family_id = family.map{|x| x.id}
 person_id = family.first.person_id
 post families_delete_multiple_url(:ids=>family_id,:person_id => person_id), :format => 'js'
 visit person_path(person_id)
end

Maka /^saya seharusnya memiliki (\d+) keluarga berdasarkan person dengan employee_identification_number = "([^"]*)"$/ do |arg1, arg2|
  people = Person.find_by_employee_identification_number(arg2)
  family = Family.all(:conditions => "person_id=#{people.id}")
  family.count.should == arg1.to_i
end