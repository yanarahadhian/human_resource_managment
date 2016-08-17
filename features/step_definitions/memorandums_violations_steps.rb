Maka /^saya seharusnya memiliki (\d+) pelanggaran berdasarkan person dengan employee_identification_number = "([^"]*)"$/ do |arg1, arg2|
  person = Person.find_by_employee_identification_number(arg2)
  violations = person.violations
  violations.count.should == arg1.to_i
end

Maka /^saya seharusnya memiliki (\d+) SP$/ do |arg1|
  violations = Violation.all(:conditions => "company_id = #{session[:platform_user]["user"]["user_company"]["id"]}")
  violations.count.should == arg1.to_i
end

Ketika /^saya mencentang "([^"]*)" pada pelanggaran dengan id = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)
  ids = Violation.find(:all, :conditions => "id = #{arg2}")
  @data = ids
end

Ketika /^saya mencentang "([^"]*)" pada SP dengan id = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)
  ids = Violation.find(:all, :conditions => "id = #{arg2}")
  @data = ids
end

Ketika /^saya menghapus pelanggaran$/ do
  post violations_delete_multiple_url(:ids=>@data,:person_id => @data.first.person_id), :format => 'js'
  visit "/people/#{@data.first.person_id}/employments"
end

Ketika /^saya menghapus SP$/ do
  post violations_delete_multiple_url(:ids=>@data,:person_id => @data.first.person_id), :format => 'js'
  visit "/memorandums"
end


When /^I visit to memorandums page with person firstname: "([^"]*)"$/ do |arg1|
  person = Person.find_by_firstname("#{arg1}")
  visit "memorandums/new?pers_id=#{person.id}"
end

Then /^I should have (\d+) memorandums?$/ do |num|
  Violation.count.should == num.to_i
end