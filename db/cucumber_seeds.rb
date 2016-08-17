puts "===== Populating Worktime for Test ====="
company_id = 32
WorkTime.create_or_update(:id => 1, :company_id => company_id, :start_time => "08:00:00", :end_time => "17:00:00", :length_in_hours => 8, :break_length_in_minutes => 60, :break_per_hour_in_minutes => 0, :compulsory_overtime_in_minutes => 0)

puts "===== Populating National Holiday for Test ====="
NationalHoliday.create_or_update(:id => 1, :company_id => company_id, :holiday_start_date => Date.parse("2011-08-17"), :holiday_end_date => Date.parse("2011-08-17"), :holiday_name => "HUT RI ke-66", :holiday_duration => 1, :leave_duration => 0)
NationalHoliday.create_or_update(:id => 2, :company_id => 31, :holiday_start_date => Date.parse("2011-08-17"), :holiday_end_date => Date.parse("2011-08-17"), :holiday_name => "HUT RI ke-66", :holiday_duration => 1, :leave_duration => 0)
NationalHoliday.create_or_update(:id => 3, :company_id => company_id, :holiday_start_date => Date.parse("2011-08-29"), :holiday_end_date => Date.parse("2011-09-02"), :holiday_name => "Idul fitri dan cuti bersama", :holiday_duration => 5, :leave_duration => 3)

puts "===== Populating Employee for Test ====="
Person.delete_all
Person.create_or_update(:id => 1, :firstname => "Nungky", :lastname => "Selection", :employee_identification_number=>11, :company_id => company_id, :tax_status_id => 1, :employment_date=> Date.today, :latest_employment_id=> 1, :color_blind=> "tidak", :known_illnesses=> "Penyakit paru-paru basah",  :nama_kontak_darurat=> "Rama", :no_telp_kontak_darurat=> "02291984910")
Person.create_or_update(:id => 2, :firstname => "Devi", :lastname => "Puspitasari", :employee_identification_number=>22, :company_id => company_id, :tax_status_id => 1, :employment_date=> Date.today, :latest_employment_id=> 2, :color_blind=> "Ya", :known_illnesses=> "A",  :nama_kontak_darurat=> "Shinta", :no_telp_kontak_darurat=> "02291984911")

puts "===== Populating Family for Test ====="
Family.delete_all
Family.create_or_update(:id => 1, :person_id => 1, :full_name => "Asmiranda", :gender=> "wanita")
Family.create_or_update(:id => 2, :person_id => 2, :full_name => "Rahmat hidayat", :gender=> "pria")

puts "===== Populating Salary master data for Test ====="
SalaryMasterData.delete_all
SalaryMasterData.create_or_update(:id => 1, :basic_salary => 30000000, :cooperation_cut=> 25000, :company_id => company_id, :person_id => 1, :valid_from => "01/01/2012" )

puts "===== Populating Salary master history data for Test ====="
SalaryMasterDataHistory.delete_all
SalaryMasterDataHistory.create_or_update(:salary_master_data_id => 1, :basic_salary => 30000000, :cooperation_cut=> 25000, :company_id => company_id, :person_id => 1, :valid_from => "01/01/2012" )

puts "===== Populating Address for Test ====="
Address.delete_all
Address.create_or_update(:id => 1, :owner_type=> "Person", :owner_id=> 1, :city => "Bandung barat", :state => "Jawa Barat", :street1 => "Kompleks Puspa Regency Blok A No 1")
Address.create_or_update(:id => 2, :owner_type=> "Person", :owner_id=> 1, :city => "Bandung barat", :state => "Jawa Barat", :street1 => "Kompleks pasar johar")
Address.create_or_update(:id => 3, :owner_type=> "Person", :owner_id=> 2, :city => "Kota Cimahi", :state => "Jawa Barat", :street1 => "Cijeungjing")
Address.create_or_update(:id => 4, :owner_type=> "Family", :owner_id=> 1, :city => "Bandung tengah", :state => "Jawa Barat", :street1 => "Jl karapitan 100")

puts "===== Populating contract type for Test ====="
ContractType.create_or_update(:id => 1, :contract_type_name=> "Kontrak Bulanan")
ContractType.create_or_update(:id => 2, :contract_type_name=> "Harian Tetap")
ContractType.create_or_update(:id => 3, :contract_type_name=> "Harian Kontrak")
ContractType.create_or_update(:id => 4, :contract_type_name=> "Bulanan Tetap")
ContractType.create_or_update(:id => 5, :contract_type_name=> "Bulanan Kontrak")

puts "===== Populating work contract for Test ====="
WorkContract.delete_all
WorkContract.create_or_update(:id=> 1, :person_id=> 1, :contract_type_id=>1, :contract_start => "2010-09-17", :contract_end=> "2011-09-19", :is_daily_employee=>0, :is_permanent_employee=>0)
WorkContract.create_or_update(:id=> 2, :person_id=> 1, :contract_type_id=>2, :contract_start => "2011-09-19", :contract_end=> "2012-09-19", :is_daily_employee=>1, :is_permanent_employee=>1)

puts "===== Populating training for Test ====="
Training.delete_all
Training.create_or_update(:id=> 1, :person_id=>1, :person_trained_in=> "Jack fernandes", :training_start=> "2010-09-17", :training_end => "2011-09-19")
Training.create_or_update(:id=> 2, :person_id=>1, :person_trained_in=> "Ferdinand heru", :training_start=> "2010-03-14", :training_end => "2010-09-13")
Training.create_or_update(:id=> 3, :person_id=>1, :person_trained_in=> "Ahmad setiawan", :training_start=> "2010-05-11", :training_end => "2010-06-19")

puts "===== Populating violation for Test ====="
Violation.delete_all
Violation.create_or_update(:id=> 1, :person_id=>1, :violation_category=> "Ringan", :action_taken	=> "SP1", :occurence_date => "2011-09-19", :active_until=> "2011-12-19", :company_id => company_id)
Violation.create_or_update(:id=> 2, :person_id=>1, :violation_category=> "Sedang", :action_taken => "SP2", :occurence_date => "2011-09-30", :active_until=> "2011-12-12", :company_id => company_id)
Violation.create_or_update(:id=> 3, :person_id=>1, :violation_category=> "Berat", :action_taken => "SP3", :occurence_date => "2011-10-12", :active_until=> "2011-11-13", :company_id => company_id)

puts "===== Populating Accident for Test ====="
Accident.delete_all
data = {:id =>1, :accident_person_in_charge => "Amat sabar", :accident_location=> "cilaki", :causes => "Ditabrak mobil", :accident_date => "2011-09-23", :action_taken=> "Berat", :person_id=> 1, :company_id => company_id}
Accident.create_or_update(data)

puts "===== Populating Education for Test ====="
Education.delete_all
Education.create_or_update(:id =>1, :person_id=> 1, :pendidikan_terakhir => "S1", :no_ijazah=> "11222", :gpa=> 7.7)

puts "===== Populating Previous company for Test ====="
PreviousCompany.delete_all
PreviousCompany.create_or_update(:id =>1, :company_name=>"PT Sampoerna TBK")

puts "===== Populating Experiences for Test ====="
Experience.delete_all
Experience.create_or_update(:id =>1, :experience_type=>"work", :person_id=> 1, :company_name => "PT. WGS", :start_date => 2003,:end_date => 2005, :division=> "Humas", :position_held => "Sekretaris", :previous_company_id => 1)
Experience.create_or_update(:id =>2, :experience_type=>"organizational", :person_id=> 1, :company_name => "Lembaga bantuan hukum organisations", :start_date => 2003,:end_date => 2005, :division=> "IT", :position_held => "Training")

puts "===== Populating Honor for test"
Honor.delete_all
Honor.create_or_update(:id => 1,:person_id => 1, :salary => 2000000, :overtime_compensation => 92485, :final_take_home_pay => 2059015, :gross_income => 2092485, :position_expenses => 104624, :month_net_income => 1987861, :year_net_income =>23854335, :ptkp => 17160000, :pkp => 6694000, :pph_indebted_per_month => 33470, :pph_indebted_per_year => 401640, :company_id => company_id)

puts "===== Populating Department for Test ====="
# Populating Department for Test
Department.delete_all
Department.create_or_update(:id => 601, :company_id => company_id, :department_name => 'Accounting', :department_code => 'ACC')
Department.create_or_update(:id => 602, :company_id => company_id, :department_name => 'CK', :department_code => 'CK')
Department.create_or_update(:id => 603, :company_id => company_id, :department_name => 'Dyeing Knitting', :department_code => 'D&K')
Department.create_or_update(:id => 604, :company_id => company_id, :department_name => 'Engraving', :department_code => 'EN')
Department.create_or_update(:id => 605, :company_id => company_id, :department_name => 'Finishing', :department_code => 'FIN')
Department.create_or_update(:id => 606, :company_id => company_id, :department_name => 'Follow Up', :department_code => 'FU')
Department.create_or_update(:id => 607, :company_id => company_id, :department_name => 'Gudang Jadi', :department_code => 'GJ')
Department.create_or_update(:id => 608, :company_id => company_id, :department_name => 'Gudang Eksport', :department_code => 'GE')
Department.create_or_update(:id => 609, :company_id => company_id, :department_name => 'Gudang PFP', :department_code => 'PFP')
Department.create_or_update(:id => 610, :company_id => company_id, :department_name => 'Gudang Winding', :department_code => 'GW')
Department.create_or_update(:id => 611, :company_id => company_id, :department_name => 'HR&GA', :department_code => 'HR&GA')
Department.create_or_update(:id => 612, :company_id => company_id, :department_name => 'Inspecting', :department_code => 'IN')
Department.create_or_update(:id => 613, :company_id => company_id, :department_name => 'Knitting', :department_code => 'KNIT')
Department.create_or_update(:id => 614, :company_id => company_id, :department_name => 'Lab', :department_code => 'LAB')
Department.create_or_update(:id => 615, :company_id => company_id, :department_name => 'Mc.Foil', :department_code => 'MF')
Department.create_or_update(:id => 616, :company_id => company_id, :department_name => 'Mkt.Dev', :department_code => 'MD')
Department.create_or_update(:id => 617, :company_id => company_id, :department_name => 'Pembelian', :department_code => 'BUY')
Department.create_or_update(:id => 618, :company_id => company_id, :department_name => 'PPC', :department_code => 'PPC')
Department.create_or_update(:id => 619, :company_id => company_id, :department_name => 'Printing', :department_code => 'PRN')
Department.create_or_update(:id => 620, :company_id => company_id, :department_name => 'Produksi', :department_code => 'PROD')
Department.create_or_update(:id => 621, :company_id => company_id, :department_name => 'R&D', :department_code => 'R&D')
Department.create_or_update(:id => 622, :company_id => company_id, :department_name => 'Teknik', :department_code => 'TEC')
Department.create_or_update(:id => 623, :company_id => company_id, :department_name => 'Trace Comp', :department_code => 'TCOM')

puts "===== Populating Division for Test ====="
# Populating Division for Test
Division.delete_all
Division.create_or_update(:id => 3111, :name => 'Accounting', :company_id => company_id, :department_id => 601, :division_code => 'ACC')
Division.create_or_update(:id => 3112, :name => 'EDP', :company_id => company_id, :department_id => 601, :division_code => 'EDP')
Division.create_or_update(:id => 3113, :name => 'Gudang Jadi Ekspedisi', :company_id => company_id, :department_id => 601, :division_code => 'GJE')
Division.create_or_update(:id => 3114, :name => 'Gudang Sparepart', :company_id => company_id, :department_id => 601, :division_code => 'GS')
Division.create_or_update(:id => 3115, :name => 'Keuangan', :company_id => company_id, :department_id => 601, :division_code => 'KEU')
Division.create_or_update(:id => 3116, :name => 'Colour Kitchen', :company_id => company_id, :department_id => 602, :division_code => 'CK')
Division.create_or_update(:id => 3117, :name => 'Dyeing Knitting', :company_id => company_id, :department_id => 603, :division_code => 'DK')
Division.create_or_update(:id => 3118, :name => 'Lab Dyeing', :company_id => company_id, :department_id => 603, :division_code => 'LD')
Division.create_or_update(:id => 3119, :name => 'Engraving', :company_id => company_id, :department_id => 604, :division_code => 'EN')
Division.create_or_update(:id => 3120, :name => 'Dryer', :company_id => company_id, :department_id => 605, :division_code => 'DRY')
Division.create_or_update(:id => 3121, :name => 'Finishing', :company_id => company_id, :department_id => 605, :division_code => 'FIN')
Division.create_or_update(:id => 3122, :name => 'Stenter', :company_id => company_id, :department_id => 605, :division_code => 'STEN')
Division.create_or_update(:id => 3123, :name => 'Washing', :company_id => company_id, :department_id => 605, :division_code => 'WASH')
Division.create_or_update(:id => 3124, :name => 'Follow Up', :company_id => company_id, :department_id => 606, :division_code => 'FOL')
Division.create_or_update(:id => 3125, :name => 'Pengiriman', :company_id => company_id, :department_id => 607, :division_code => 'GJKIR')
Division.create_or_update(:id => 3126, :name => 'Gudang Eksport', :company_id => company_id, :department_id => 608, :division_code => 'GE')
Division.create_or_update(:id => 3127, :name => 'Gudang PFP', :company_id => company_id, :department_id => 609, :division_code => 'PFP')
Division.create_or_update(:id => 3128, :name => 'Gudang Winding', :company_id => company_id, :department_id => 610, :division_code => 'GW')
Division.create_or_update(:id => 3129, :name => 'Hanger Sample', :company_id => company_id, :department_id => 610, :division_code => 'HANG')
Division.create_or_update(:id => 3130, :name => 'Pengiriman', :company_id => company_id, :department_id => 610, :division_code => 'GWKIR')
Division.create_or_update(:id => 3131, :name => 'GA', :company_id => company_id, :department_id => 611, :division_code => 'GA')
Division.create_or_update(:id => 3132, :name => 'HR&GA', :company_id => company_id, :department_id => 611, :division_code => 'HR')
Division.create_or_update(:id => 3133, :name => 'Keamanan', :company_id => company_id, :department_id => 611, :division_code => 'SEC')
Division.create_or_update(:id => 3134, :name => 'Kenek', :company_id => company_id, :department_id => 611, :division_code => 'KNK')
Division.create_or_update(:id => 3135, :name => 'Supir', :company_id => company_id, :department_id => 611, :division_code => 'DRV')
Division.create_or_update(:id => 3136, :name => 'Umum', :company_id => company_id, :department_id => 611, :division_code => 'GEN')
Division.create_or_update(:id => 3137, :name => 'Inspecting', :company_id => company_id, :department_id => 612, :division_code => 'INS')
Division.create_or_update(:id => 3138, :name => 'Knitting', :company_id => company_id, :department_id => 613, :division_code => 'KNIT')
Division.create_or_update(:id => 3139, :name => 'Lab', :company_id => company_id, :department_id => 614, :division_code => 'LAB')
Division.create_or_update(:id => 3140, :name => 'Mc.Foil', :company_id => company_id, :department_id => 615, :division_code => 'MF')
Division.create_or_update(:id => 3141, :name => 'Mkt.Dev', :company_id => company_id, :department_id => 616, :division_code => 'MD')
Division.create_or_update(:id => 3142, :name => 'Pembelian', :company_id => company_id, :department_id => 617, :division_code => 'BUY')
Division.create_or_update(:id => 3143, :name => 'PPC', :company_id => company_id, :department_id => 618, :division_code => 'PPC')
Division.create_or_update(:id => 3144, :name => 'Printing', :company_id => company_id, :department_id => 618, :division_code => 'PRN')
Division.create_or_update(:id => 3145, :name => 'Steamer', :company_id => company_id, :department_id => 619, :division_code => 'STEAM')
Division.create_or_update(:id => 3146, :name => 'Colour Kitchen', :company_id => company_id, :department_id => 620, :division_code => 'C K')
Division.create_or_update(:id => 3147, :name => 'Dyeing Knitting', :company_id => company_id, :department_id => 620, :division_code => 'D&K')
Division.create_or_update(:id => 3148, :name => 'Stenter', :company_id => company_id, :department_id => 620, :division_code => 'STE')
Division.create_or_update(:id => 3149, :name => 'R&D', :company_id => company_id, :department_id => 621, :division_code => 'R&D')
Division.create_or_update(:id => 3150, :name => 'Teknik', :company_id => company_id, :department_id => 622, :division_code => 'TECH')
Division.create_or_update(:id => 3151, :name => 'Trace Comp', :company_id => company_id, :department_id => 623, :division_code => 'TECOM')

puts "===== Populating Position for Test ====="
# Populating Position for Test
Position.create_or_update(:id => 101, :company_id => company_id, :position_name => 'Anggota')
Position.create_or_update(:id => 102, :company_id => company_id, :position_name => 'Foreman')
Position.create_or_update(:id => 103, :company_id => company_id, :position_name => 'Inspector')
Position.create_or_update(:id => 104, :company_id => company_id, :position_name => 'Jr. Wakaru')
Position.create_or_update(:id => 105, :company_id => company_id, :position_name => 'Kabag')
Position.create_or_update(:id => 106, :company_id => company_id, :position_name => 'Karu')
Position.create_or_update(:id => 107, :company_id => company_id, :position_name => 'Kashift')
Position.create_or_update(:id => 108, :company_id => company_id, :position_name => 'Kasie')
Position.create_or_update(:id => 109, :company_id => company_id, :position_name => 'Kasubie')
Position.create_or_update(:id => 110, :company_id => company_id, :position_name => 'Manager')
Position.create_or_update(:id => 111, :company_id => company_id, :position_name => 'Operator')
Position.create_or_update(:id => 112, :company_id => company_id, :position_name => 'Staff')
Position.create_or_update(:id => 113, :company_id => company_id, :position_name => 'Wakabag')
Position.create_or_update(:id => 114, :company_id => company_id, :position_name => 'Wakaru')
Position.create_or_update(:id => 115, :company_id => company_id, :position_name => 'Wandanru')

puts "===== Populating Employments for Test ====="
Employment.delete_all
Employment.create_or_update(:id => 1, :person_id => 1, :employment_start => "2011-12-01",	:department_id=> 601, :work_division_id => 3111,:position_id => 101, :change_from_before => "masuk_kerja" )
Employment.create_or_update(:id => 2, :person_id => 2, :employment_start => "2011-12-02",	:department_id=> 602, :work_division_id => 3112,:position_id => 102, :change_from_before => "mutasi" )


puts "===== Populating Tax Status for Test ====="
# Populating Tax Status for Test
TaxStatus.create_or_update(:id => 1, :tax_status_code => 'T/0', :ptkp => 1320000)
TaxStatus.create_or_update(:id => 2, :tax_status_code => 'T/1', :ptkp => 1430000)
TaxStatus.create_or_update(:id => 3, :tax_status_code => 'T/2', :ptkp => 1540000)
TaxStatus.create_or_update(:id => 4, :tax_status_code => 'T/3', :ptkp => 1650000)
TaxStatus.create_or_update(:id => 5, :tax_status_code => 'K/0', :ptkp => 1430000)
TaxStatus.create_or_update(:id => 6, :tax_status_code => 'K/1', :ptkp => 1540000)
TaxStatus.create_or_update(:id => 7, :tax_status_code => 'K/2', :ptkp => 1650000)
TaxStatus.create_or_update(:id => 8, :tax_status_code => 'K/3', :ptkp => 1760000)

puts "===== Populating Contact Type for Test ====="
# Populating Contact Type for Test
ContractType.create_or_update(:id => 1, :company_id => company_id, :contract_type_name => 'Tetap Harian')
ContractType.create_or_update(:id => 2, :company_id => company_id, :contract_type_name => 'Tetap Bulanan')
ContractType.create_or_update(:id => 3, :company_id => company_id, :contract_type_name => 'Kontrak Harian')
ContractType.create_or_update(:id => 4, :company_id => company_id, :contract_type_name => 'Kontrak Bulanan')

puts "===== Populating Premiums for Test ====="
# Populating Premiums for Test
Premium.delete_all
Premium.create_or_update(
    :id => 1,
    :premium_name => "Premi Masa Kerja",
    :calculated_automatically => true,
    :company_id => company_id,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true
)
Premium.create_or_update(
    :id => 2,
    :premium_name => "Premi Jabatan",
    :calculated_automatically => true,
    :company_id => company_id,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true
)
Premium.create_or_update(
    :id => 3,
    :premium_name => "Premi Hadir Bulanan",
    :calculated_automatically => true,
    :company_id => company_id,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true
)
Premium.create_or_update(
    :id => 4,
    :premium_name => "Premi Bersyarat",
    :calculated_automatically => true,
    :company_id => company_id,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true
)

puts "===== Populating Premiums In Company for Test ====="
# Populating Premiums In Company for Test
PremiumsInCompany.create_or_update(
    :id => 1,
    :company_id => company_id,
    :premium_id => 1,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true,
    :count_daily => false
)
PremiumsInCompany.create_or_update(
    :id => 2,
    :company_id => company_id,
    :premium_id => 2,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true,
    :count_daily => false
)
PremiumsInCompany.create_or_update(
    :id => 3,
    :company_id => company_id,
    :premium_id => 3,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true,
    :count_daily => false
)
PremiumsInCompany.create_or_update(
    :id => 4,
    :company_id => company_id,
    :premium_id => 4,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true,
    :count_daily => false
)

HrSetting.create_or_update(
    :id => 32,
    :company_id => company_id,
    :lateness_tolerance_in_minutes => 30,
    :period_in_minutes => 60,
    :leaves_first_year_quota => 12,
    :leaves_quota_per_year => 12
)
PayrollSetting.create_or_update(
    :id => 32,
    :company_id => company_id,
    :full_working_days => 30,
    :company_cover_jamsostek => 100,
    # :bca_branch_code => ,
    # :bca_company_code => ,
    # :bca_company_initial => ,
    # :bca_company_account_number => ,
    :payroll_by_bca => false
)

