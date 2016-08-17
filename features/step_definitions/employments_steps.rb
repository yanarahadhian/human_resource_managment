Maka /^saya seharusnya memiliki (\d+) employment berdasarkan person dengan employee_identification_number = "([^"]*)"$/ do |arg1, arg2|
  person = Person.find_by_employee_identification_number(arg2)
  person.employments.count.should == arg1.to_i
end

When /^I visit to employment page with firstname: "([^"]*)"$/ do |arg1|
  person = Person.find_by_firstname("#{arg1}")
  visit person_employments_path(person)
end

Given /^(?:|I )am on the employment page with firstname: "([^"]*)"$/ do |arg1|
  person = Person.find_by_firstname("#{arg1}")
  visit person_employments_path(person)
end

Then /^I should have (\d+) employment?$/ do |num|
  Employment.count.should == num.to_i
end