Ketika /^saya mencentang "([^"]*)" pada pendidikan dengan id = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)
  ids = Education.find(:all, :conditions => "id = #{arg2}")
  @data = ids
end

Ketika /^saya menghapus pendidikan$/ do
  post  educations_delete_multiple_url(:ids=>@data,:person_id => @data.first.person_id), :format => 'js'
  visit "/history/#{@data.first.person_id}"
end

Maka /^saya seharusnya memiliki (\d+) pendidikan berdasarkan person dengan employee_identification_number = "([^"]*)"$/ do |arg1, arg2|
  people = Person.find_by_employee_identification_number(arg2)
  people.educations.count.should == arg1.to_i
end