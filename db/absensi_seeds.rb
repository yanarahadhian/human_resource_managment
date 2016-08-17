
# "===== Populating Worktime for Test ====="
WorkTime.create_or_update(:id => 1, :company_id => 32, :start_time => "08:00:00", :end_time => "17:00:00", :length_in_hours => 8, :break_length_in_minutes => 60, :break_per_hour_in_minutes => 0, :compulsory_overtime_in_minutes => 0)
WorkTime.create_or_update(:id => 2, :company_id => 32, :start_time => "08:00:00", :end_time => "17:00:00", :length_in_hours => 7, :break_length_in_minutes => 60, :break_per_hour_in_minutes => 0, :compulsory_overtime_in_minutes => 60)

# "===== Populating Shifts for Test ====="
Shift.create_or_update(:id => 1,:company_id => 32, :shift_name => "Normal Shift", :shift_code => "N", :working_hour_per_week => 40,
  :monday_time_id => 1, :tuesday_time_id => 1, :wednesday_time_id => 1,
  :thursday_time_id => 1, :friday_time_id => 1, :saturday_time_id => 1)
Shift.create_or_update(:id => 2, :company_id => 32, :shift_name => "Normal Shift with cumpolsory overtimes", :shift_code => "NC", :working_hour_per_week => 40,
  :monday_time_id => 2, :tuesday_time_id => 2, :wednesday_time_id => 2,
  :thursday_time_id => 2, :friday_time_id => 2, :saturday_time_id => 2)


# "===== Populating Employee for Test ====="
Person.create_or_update(:id => 10, :firstname => "Test", :lastname => "Present Today", :employee_identification_number=>110, :company_id => 32, :tax_status_id => 1, :employment_date => Date.today - 1.year, :latest_employment_id=> 10, :color_blind=> "tidak", :blood_type=> "O",  :nama_kontak_darurat=> "Rama", :no_telp_kontak_darurat=> "02291984910")
Person.create_or_update(:id => 11, :firstname => "Test", :lastname => "Absent Today", :employee_identification_number=>111, :company_id => 32, :tax_status_id => 1, :employment_date => Date.today - 6.month, :latest_employment_id=> 11, :color_blind=> "Ya", :blood_type=> "A",  :nama_kontak_darurat=> "Shinta", :no_telp_kontak_darurat=> "02291984911")

# "===== Populating Employments for Test ====="
Employment.create_or_update(:id => 10, :person_id => 10, :employment_start => Date.today - 1.year,	:department_id=> 601, :work_division_id => 3111,:position_id => 101, :change_from_before => "masuk_kerja" )
Employment.create_or_update(:id => 11, :person_id => 11, :employment_start => Date.today - 6.month,	:department_id=> 602, :work_division_id => 3112,:position_id => 102, :change_from_before => "masuk_kerja" )

# "===== Populating Schedule for Test ====="
EmployeeShift.create_or_update(:id => 1, :person_id => 10, :company_id => 32, :shift_id => 1, :shift_from => Date.today - 1.month, :shift_to => Date.tomorrow)
EmployeeShift.create_or_update(:id => 11, :person_id => 11, :company_id => 32, :shift_id => 2, :shift_from => Date.today - 1.month, :shift_to => Date.tomorrow)

# "===== Populating Presence for Test ====="
Presence.login(Person.find(10), Time.parse("#{Date.yesterday.strftime("%Y-%m-%d")} 08:05"))
Presence.logout(Person.find(10), Time.parse("#{Date.yesterday.strftime("%Y-%m-%d")} 12:05"))
Presence.login(Person.find(10), Time.parse("#{Date.yesterday.strftime("%Y-%m-%d")} 12:55"))
Presence.logout(Person.find(10), Time.parse("#{Date.yesterday.strftime("%Y-%m-%d")} 17:05"))
Presence.login(Person.find(10), Time.parse("#{Date.today.strftime("%Y-%m-%d")} 08:45"))
Presence.logout(Person.find(10), Time.parse("#{Date.today.strftime("%Y-%m-%d")} 12:00"))
Presence.login(Person.find(10), Time.parse("#{Date.today.strftime("%Y-%m-%d")} 12:45"))
Presence.logout(Person.find(10), Time.parse("#{Date.today.strftime("%Y-%m-%d")} 17:15"))
Presence.login(Person.find(11), Time.parse("#{Date.yesterday.strftime("%Y-%m-%d")} 08:00"))
Presence.logout(Person.find(11), Time.parse("#{Date.yesterday.strftime("%Y-%m-%d")} 12:01"))
Presence.login(Person.find(11), Time.parse("#{Date.yesterday.strftime("%Y-%m-%d")} 13:04"))
Presence.logout(Person.find(11), Time.parse("#{Date.yesterday.strftime("%Y-%m-%d")} 17:05"))