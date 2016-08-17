Then /^I should have (\d+) national_holidays$/ do |num|
  @holidays = NationalHoliday.all(:conditions => ['company_id = ?', session[:platform_user]['user']['user_company']['id'].to_i])
  @holidays.count.should == num.to_i
end

When /^I set filter on holidays page$/ do
  visit("/holidays", :get, {:filter => {:date => "2011-08-17"}})
end

Given /^I have no national holidays$/ do
  NationalHoliday.delete_all
end
