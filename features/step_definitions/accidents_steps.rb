Ketika /^saya mencentang "([^"]*)" pada kecelakaan dengan id = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)
  ids = Accident.find(:all, :conditions => "id = #{arg2}")
  @data = ids
end

Ketika /^saya menghapus kecelakaan$/ do
  post  accidents_delete_multiple_url(:ids=>@data,:person_id => @data.first.person_id), :format => 'js'
  visit "/people/#{@data.first.person_id}/employments"
end

Ketika /^saya mencentang "([^"]*)" pada kecelakaan kerja dengan id = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)
  ids = Accident.find(:all, :conditions => "id = #{arg2}")
  @data = ids
end

Ketika /^saya menghapus kecelakaan kerja$/ do
  post  accidents_delete_multiple_url(:ids=>@data,:person_id => @data.first.person_id), :format => 'js'
  visit "/job_accidents"
end


Maka /^saya seharusnya memiliki (\d+) kecelakaan berdasarkan person dengan employee_identification_number = "([^"]*)"$/ do |arg1, arg2|
  people = Person.find_by_employee_identification_number(arg2)
  people.accidents.count.should == arg1.to_i
end

Maka /^saya seharusnya memiliki (\d+) kecelakaan kerja$/ do |arg1|
  accidents = Accident.all(:conditions => "company_id = #{session[:platform_user]["user"]["user_company"]["id"]}")
  accidents.count.should == arg1.to_i
end