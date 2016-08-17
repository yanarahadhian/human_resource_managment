Maka /^saya seharusnya memiliki (\d+) data gaji master$/ do |arg1|
  salary = SalaryMasterData.all(:conditions => "company_id = #{session[:platform_user]["user"]["user_company"]["id"]}")
  salary.count.should == arg1.to_i
end

Maka /^Maka saya seharusnya memiliki (\d+) data gaji master salary$/ do |arg1|
  salary = SalaryMasterDataHistory.all(:conditions => "company_id = #{session[:platform_user]["user"]["user_company"]["id"]}")
  salary.count.should == arg1.to_i
end

Maka /^saya seharusnya memiliki (\d+) data gaji$/ do |arg1|
  honor = Honor.all(:conditions => "company_id = #{session[:platform_user]["user"]["user_company"]["id"]}")
  honor.count.should == arg1.to_i
end


Ketika /^saya upload a file master "([^"]*)"$/ do |filename|
  attach_file("input_import", File.join(RAILS_ROOT, 'features', 'upload-files', "#{filename}"))
  click_button "Simpan"
end