Ketika /^saya mencentang "([^"]*)" pada pelatihan dengan id = "([^"]*)"$/ do |arg1, arg2|
  check(arg1)
  ids = Training.all(:conditions => "id=#{arg2}")
  @data = ids
end

Ketika /^saya menghapus pelatihan$/ do
  post trainings_delete_multiple_url(:ids=>@data,:person_id => @data.first.person_id), :format => 'js'
  visit person_path(@data.first.person_id)
end

Maka /^saya seharusnya memiliki (\d+) pelatihan berdasarkan person dengan employee_identification_number = "([^"]*)"$/ do |arg1, arg2|
  people = Person.find_by_employee_identification_number(arg2)
  people.trainings.count.should == arg1.to_i
end

Then /^I should have (\d+) trainings?$/ do |num|
  Training.count.should == num.to_i
end