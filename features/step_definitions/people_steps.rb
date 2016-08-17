Ketika /^saya mencentang "([^"]*)" dengan employee_identification_number = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)
  ids = Person.find(:all, :conditions => "employee_identification_number = #{arg2}")
  @data = ids
end

Ketika /^saya menghapus people$/ do
  post people_delete_multiple_url(:ids=>@data), :format => 'js'
  visit people_path
end

Maka /^saya harus memiliki (\d+) person$/ do |arg1|
  Person.count.should == arg1.to_i
end

Given /^(\d+) employee?$/ do |num|
  Person.delete_all
  if num.to_i > 0
    (1..num.to_i).each do |i|
      data = {:firstname => "firstname#{i}",:lastname=>"lastname#{i}", :employee_identification_number=>i,:company_id=>1, :tax_status_id =>i, :employment_date=> Date.today()}
      p = Person.new(data)
      p.save
    end
  end
end

Given /^I have the following person:$/ do |table|
  Person.delete_all
  table.hashes.each do |person_hash|
    Person.create! person_hash do |p|
    end
  end
end

Then /^I should have (\d+) person?$/ do |num|
  Person.count.should == num.to_i
end

When /^I find the edit person with firstname = "([^"]*)"$/ do |args|
  p = Person.find_by_firstname(args)
  edit_person_path(p)
end

When /^I see the ([^"]*) page for person with (.*)?$/ do |link, conditions|
  person = Person.find(:first, :conditions => conditions.gsub(/:\s?/, " = ").gsub(/,\s?/, " AND "))
  visit history_path(person.id)
end

When /^I visit to person page with firstname: "([^"]*)"$/ do |arg1|
  person = Person.find_by_firstname("#{arg1}")
  visit person_path(person)
end

When /^I visit to health page with firstname: "([^"]*)"$/ do |arg1|
  person = Person.find_by_firstname("#{arg1}")
  visit edit_health_path(person)
end

When /^(?:|I )check "([^"]*)" for "([^"]*)" with (.*)$/ do |checkbox, model_name, pconditions|
conditions = pconditions.gsub(/:\s?/, " = ")
 begin
   field = checkbox
   ids = Person.find(:first, :conditions => conditions).id if model_name == "people"
   ids = Family.find(:first, :conditions => conditions).id if model_name == "family"
   ids = Address.find(:first, :conditions => conditions).id if model_name == "address"
   check(field)
   @data.nil? ? (@data = [ids]) : (@data << ids)
 rescue Object => e
   raise "Can't find #{model_name} with conditions \"#{conditions}\""
 end
end

When /^I delete people?$/ do
 person_id = Person.find(:all, :conditions => "id in (#{@data.join(',')})").map{|x| x.id}
 post people_delete_multiple_url(:ids=>person_id), :format => 'js'
 visit people_path
end

When /^I press "([^"]*)" on health page with person firstname : "([^"]*)" ?$/ do |btn_name, person_firstname|
 person = Person.find_by_firstname(person_firstname)
 click_button(btn_name)
 visit person_path(person)
end
