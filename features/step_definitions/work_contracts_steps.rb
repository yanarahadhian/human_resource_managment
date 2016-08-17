Then /^I should have (\d+) work contracts?$/ do |num|
  WorkContract.count.should == num.to_i
end