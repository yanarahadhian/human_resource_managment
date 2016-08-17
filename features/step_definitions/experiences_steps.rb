Ketika /^saya mencentang "([^"]*)" pada pekerjaan dengan id = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)
  ids = Experience.all(:conditions => "id=#{arg2}")
  @data = ids
end

Ketika /^saya menghapus pekerjaan$/ do
  post experiences_delete_multiple_url(:ids=>@data,:person_id => @data.first.person_id), :format => 'js'
  visit "/history/#{@data.first.person_id}?tab=2"
end

Ketika /^saya mencentang "([^"]*)" pada organisasi dengan id = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)
  ids = Experience.all(:conditions => "id=#{arg2}")
  @data = ids
end

Ketika /^saya menghapus organisasi$/ do
  post experiences_delete_multiple_url(:ids=>@data,:person_id => @data.first.person_id), :format => 'js'
  visit "/history/#{@data.first.person_id}?tab=2"
end


Maka /^saya seharusnya memiliki (\d+) riwayat pekerjaan berdasarkan person dengan employee_identification_number = "([^"]*)"$/ do |arg1, arg2|
  people = Person.find_by_employee_identification_number(arg2)
  people.experiences.find(:all,:conditions => "experience_type='work'").count.should == arg1.to_i
end

Maka /^saya seharusnya memiliki (\d+) riwayat organisasi berdasarkan person dengan employee_identification_number = "([^"]*)"$/ do |arg1, arg2|
  people = Person.find_by_employee_identification_number(arg2)
  people.experiences.find(:all,:conditions => "experience_type='organizational'").count.should == arg1.to_i
end
