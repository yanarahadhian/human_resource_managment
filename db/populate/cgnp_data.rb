puts "===== Populating Department for CGNP ====="
# Populating Department for CGNP
Department.create_or_update(:id => 601, :company_id => 123, :department_name => 'Accounting')
Department.create_or_update(:id => 602, :company_id => 123, :department_name => 'CK')
Department.create_or_update(:id => 603, :company_id => 123, :department_name => 'Dyeing Knitting')
Department.create_or_update(:id => 604, :company_id => 123, :department_name => 'Engraving')
Department.create_or_update(:id => 605, :company_id => 123, :department_name => 'Finishing')
Department.create_or_update(:id => 606, :company_id => 123, :department_name => 'Follow Up')
Department.create_or_update(:id => 607, :company_id => 123, :department_name => 'Gudang Jadi')
Department.create_or_update(:id => 608, :company_id => 123, :department_name => 'Gudang Eksport')
Department.create_or_update(:id => 609, :company_id => 123, :department_name => 'Gudang PFP')
Department.create_or_update(:id => 610, :company_id => 123, :department_name => 'Gudang Winding')
Department.create_or_update(:id => 611, :company_id => 123, :department_name => 'HR&GA')
Department.create_or_update(:id => 612, :company_id => 123, :department_name => 'Inspecting')
Department.create_or_update(:id => 613, :company_id => 123, :department_name => 'Knitting')
Department.create_or_update(:id => 614, :company_id => 123, :department_name => 'Lab')
Department.create_or_update(:id => 615, :company_id => 123, :department_name => 'Mc.Foil')
Department.create_or_update(:id => 616, :company_id => 123, :department_name => 'Mkt.Dev')
Department.create_or_update(:id => 617, :company_id => 123, :department_name => 'Pembelian')
Department.create_or_update(:id => 618, :company_id => 123, :department_name => 'PPC')
Department.create_or_update(:id => 619, :company_id => 123, :department_name => 'Prinitng')
Department.create_or_update(:id => 620, :company_id => 123, :department_name => 'Produksi')
Department.create_or_update(:id => 621, :company_id => 123, :department_name => 'R&D')
Department.create_or_update(:id => 622, :company_id => 123, :department_name => 'Teknik')
Department.create_or_update(:id => 623, :company_id => 123, :department_name =>'Trace Comp')

puts "===== Populating Division for CGNP ====="
# Populating Division for CGNP
Division.create_or_update(:id => 3111, :name => 'Accounting', :company_id => 123, :department_id => 601)
Division.create_or_update(:id => 3112, :name => 'EDP', :company_id => 123, :department_id => 601)
Division.create_or_update(:id => 3113, :name => 'Gudang Jadi Ekspedisi', :company_id => 123, :department_id => 601)
Division.create_or_update(:id => 3114, :name => 'Gudang Sparepart', :company_id => 123, :department_id => 601)
Division.create_or_update(:id => 3115, :name => 'Keuangan', :company_id => 123, :department_id => 601)
Division.create_or_update(:id => 3116, :name => 'Colour Kitchen', :company_id => 123, :department_id => 602)
Division.create_or_update(:id => 3117, :name => 'Dyeing Knitting', :company_id => 123, :department_id => 603)
Division.create_or_update(:id => 3118, :name => 'Lab Dyeing', :company_id => 123, :department_id => 603)
Division.create_or_update(:id => 3119, :name => 'Engraving', :company_id => 123, :department_id => 604)
Division.create_or_update(:id => 3120, :name => 'Dryer', :company_id => 123, :department_id => 605)
Division.create_or_update(:id => 3121, :name => 'Finishing', :company_id => 123, :department_id => 605)
Division.create_or_update(:id => 3122, :name => 'Stenter', :company_id => 123, :department_id => 605)
Division.create_or_update(:id => 3123, :name => 'Washing', :company_id => 123, :department_id => 605)
Division.create_or_update(:id => 3124, :name => 'Follow Up', :company_id => 123, :department_id => 606)
Division.create_or_update(:id => 3125, :name => 'Pengiriman', :company_id => 123, :department_id => 607)
Division.create_or_update(:id => 3126, :name => 'Gudang Eksport', :company_id => 123, :department_id => 608)
Division.create_or_update(:id => 3127, :name => 'Gudang PFP', :company_id => 123, :department_id => 609)
Division.create_or_update(:id => 3128, :name => 'Gudang Winding', :company_id => 123, :department_id => 610)
Division.create_or_update(:id => 3129, :name => 'Hanger Sample', :company_id => 123, :department_id => 610)
Division.create_or_update(:id => 3130, :name => 'Pengiriman', :company_id => 123, :department_id => 610)
Division.create_or_update(:id => 3131, :name => 'GA', :company_id => 123, :department_id => 611)
Division.create_or_update(:id => 3132, :name => 'HR&GA', :company_id => 123, :department_id => 611)
Division.create_or_update(:id => 3133, :name => 'Keamanan', :company_id => 123, :department_id => 611)
Division.create_or_update(:id => 3134, :name => 'Kenek', :company_id => 123, :department_id => 611)
Division.create_or_update(:id => 3135, :name => 'Supir', :company_id => 123, :department_id => 611)
Division.create_or_update(:id => 3136, :name => 'Umum', :company_id => 123, :department_id => 611)
Division.create_or_update(:id => 3137, :name => 'Inspecting', :company_id => 123, :department_id => 612)
Division.create_or_update(:id => 3138, :name => 'Knitting', :company_id => 123, :department_id => 613)
Division.create_or_update(:id => 3139, :name => 'Lab', :company_id => 123, :department_id => 614)
Division.create_or_update(:id => 3140, :name => 'Mc.Foil', :company_id => 123, :department_id => 615)
Division.create_or_update(:id => 3141, :name => 'Mkt.Dev', :company_id => 123, :department_id => 616)
Division.create_or_update(:id => 3142, :name => 'Pembelian', :company_id => 123, :department_id => 617)
Division.create_or_update(:id => 3143, :name => 'PPC', :company_id => 123, :department_id => 618)
Division.create_or_update(:id => 3144, :name => 'Printing', :company_id => 123, :department_id => 618)
Division.create_or_update(:id => 3145, :name => 'Steamer', :company_id => 123, :department_id => 619)
Division.create_or_update(:id => 3146, :name => 'Colour Kitchen', :company_id => 123, :department_id => 620)
Division.create_or_update(:id => 3147, :name => 'Dyeing Knitting', :company_id => 123, :department_id => 620)
Division.create_or_update(:id => 3148, :name => 'Stenter', :company_id => 123, :department_id => 620)
Division.create_or_update(:id => 3149, :name => 'R&D', :company_id => 123, :department_id => 621)
Division.create_or_update(:id => 3150, :name => 'Teknik', :company_id => 123, :department_id => 622)
Division.create_or_update(:id => 3151, :name => 'Trace Comp', :company_id => 123, :department_id => 623)

puts "===== Populating Position for CGNP ====="
# Populating Position for CGNP
Position.create_or_update(:id => 101, :company_id => 123, :position_name => 'Anggota')
Position.create_or_update(:id => 102, :company_id => 123, :position_name => 'Foreman')
Position.create_or_update(:id => 103, :company_id => 123, :position_name => 'Inspector')
Position.create_or_update(:id => 104, :company_id => 123, :position_name => 'Jr. Wakaru')
Position.create_or_update(:id => 105, :company_id => 123, :position_name => 'Kabag')
Position.create_or_update(:id => 106, :company_id => 123, :position_name => 'Karu')
Position.create_or_update(:id => 107, :company_id => 123, :position_name => 'Kashift')
Position.create_or_update(:id => 108, :company_id => 123, :position_name => 'Kasie')
Position.create_or_update(:id => 109, :company_id => 123, :position_name => 'Kasubie')
Position.create_or_update(:id => 110, :company_id => 123, :position_name => 'Manager')
Position.create_or_update(:id => 111, :company_id => 123, :position_name => 'Operator')
Position.create_or_update(:id => 112, :company_id => 123, :position_name => 'Staff')
Position.create_or_update(:id => 113, :company_id => 123, :position_name => 'Wakabag')
Position.create_or_update(:id => 114, :company_id => 123, :position_name => 'Wakaru')
Position.create_or_update(:id => 115, :company_id => 123, :position_name => 'Wandanru')

puts "===== Populating Tax Status for CGNP ====="
# Populating Tax Status for CGNP
TaxStatus.create_or_update(:id => 1, :tax_status_code => 'T/0', :ptkp => 1320000)
TaxStatus.create_or_update(:id => 2, :tax_status_code => 'T/1', :ptkp => 1430000)
TaxStatus.create_or_update(:id => 3, :tax_status_code => 'T/2', :ptkp => 1540000)
TaxStatus.create_or_update(:id => 4, :tax_status_code => 'T/3', :ptkp => 1650000)
TaxStatus.create_or_update(:id => 5, :tax_status_code => 'K/0', :ptkp => 1430000)
TaxStatus.create_or_update(:id => 6, :tax_status_code => 'K/1', :ptkp => 1540000)
TaxStatus.create_or_update(:id => 7, :tax_status_code => 'K/2', :ptkp => 1650000)
TaxStatus.create_or_update(:id => 8, :tax_status_code => 'K/3', :ptkp => 1760000)

puts "===== Populating Contact Type for CGNP ====="
# Populating Contact Type for CGNP
ContractType.create_or_update(:id => 1, :company_id => 123, :contract_type_name => 'Tetap Harian')
ContractType.create_or_update(:id => 2, :company_id => 123, :contract_type_name => 'Tetap Bulanan')
ContractType.create_or_update(:id => 3, :company_id => 123, :contract_type_name => 'Kontrak Harian')
ContractType.create_or_update(:id => 4, :company_id => 123, :contract_type_name => 'Kontrak Bulanan')

puts "===== Populating Premiums for CGNP ====="
# Populating Premiums for CGNP
Premium.create_or_update(
    :id => 1,
    :premium_name => "Premi Masa Kerja",
    :calculated_automatically => true,
    :company_id => CGNP,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true
)
Premium.create_or_update(
    :id => 2,
    :premium_name => "Premi Jabatan",
    :calculated_automatically => true,
    :company_id => CGNP,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true
)
Premium.create_or_update(
    :id => 3,
    :premium_name => "Premi Hadir Bulanan",
    :calculated_automatically => true,
    :company_id => CGNP,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true
)
Premium.create_or_update(
    :id => 4,
    :premium_name => "Premi Bersyarat",
    :calculated_automatically => true,
    :company_id => CGNP,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true
)

puts "===== Populating Premiums In Company for CGNP ====="
# Populating Premiums In Company for CGNP
PremiumsInCompany.create_or_update(
    :id => 1,
    :company_id => CGNP,
    :premium_id => 1,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true,
    :count_daily => false
)
PremiumsInCompany.create_or_update(
    :id => 2,
    :company_id => CGNP,
    :premium_id => 2,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true,
    :count_daily => false
)
PremiumsInCompany.create_or_update(
    :id => 3,
    :company_id => CGNP,
    :premium_id => 3,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true,
    :count_daily => false
)
PremiumsInCompany.create_or_update(
    :id => 4,
    :company_id => CGNP,
    :premium_id => 4,
    :calculated_on_overtime => true,
    :calculated_on_salary_cut => true,
    :count_daily => false
)

HrSetting.create_or_update(
    :id => 123,
    :company_id => 123,
    :lateness_tolerance_in_minutes => 30,
    :period_in_minutes => 60,
    :leaves_first_year_quota => 12,
    :leaves_quota_per_year => 12
)
PayrollSetting.create_or_update(
    :id => 123,
    :company_id => 123,
    :full_working_days => 30,
    :company_cover_jamsostek => 100,
    # :bca_branch_code => ,
    # :bca_company_code => ,
    # :bca_company_initial => ,
    # :bca_company_account_number => ,
    :payroll_by_bca => false
)

