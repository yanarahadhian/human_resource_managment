ActionController::Routing::Routes.draw do |map|
  #map.resources :awards

  map.performance "/performance" , :controller => 'performances', :action => 'division'
  map.thrs_setting "settings/thr" , :controller =>'thrs', :action=>'setting'
  map.setting_schedule "/settings/schedule", :controller => 'schedules', :action => 'schedules_setting'
  map.setting_payroll "settings/payroll" , :controller => 'payrolls', :action => 'setting_payroll'
  map.subsidy_setting "/settings/tunjangan_diluar_gaji", :controller=>'subsidies', :action =>'setting'
  map.overtimes "/overtimes" , :controller=>'overtimes' , :action => 'index'
  map.premium_table "/premium_table", :controller => 'payrolls', :action => 'premium_table'

  map.premium "/payroll/create_premium", :controller => 'payrolls', :action => 'create_premium'
  map.premium "/payrolls/premiums", :controller => 'payrolls', :action => 'premiums'

  map.premium "/payrolls/edit_premium/:id/:row", :controller => 'payrolls', :action => 'edit_premium'
  map.premium "/payrolls/edit_premium/:id", :controller => 'payrolls', :action => 'edit_premium'

  map.premium "/payrolls/update_premium", :controller => 'payrolls', :action => 'update_premium'
  map.tax_status "/payrolls/update_ptkp", :controller => 'payrolls', :action => 'update_ptkp'
  map.premium "/payrolls/delete_premium", :controller => 'payrolls', :action => 'delete_premium'


  map.root :controller => "user_sessions", :action => "new"
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'

  map.resources :user_sessions, :collection => [:after_login, :callback, :permalink_require, :logout_confirm, :logout_confirmed]

  map.resources :employees
  map.search_employee "/search_employee" , :controller => 'schedules', :action=> 'search_employee'
  map.add_group "/add_group/" , :controller => 'overtimes', :action=> 'add_group'
  map.change_table "/change_table/", :controller => 'schedules', :action=> 'change_table'
  map.change_table_group "/change_table_group/", :controller => 'schedules', :action=> 'change_table_group'
  map.check_schedule "/check_schedule/", :controller => 'schedules', :action=> 'check'
  map.change_group_selector "/group_selector/" , :controller => 'schedules', :action => 'change_group_selector'
  map.search_and_delete "/search_and_delete/" , :controller => 'schedules', :action => 'search_and_delete'
  # application controller route
  map.ajax_educational_institution '/ajax_educational_institution', :controller => 'application', :action => 'ajax_educational_institution'
  map.create_for_employments "/employments/create", :controller => "employments" ,:action => "create"

  # person controller route
  map.export_person_data '/people/export', :controller => 'people', :action => 'export'
  map.export_sp_data '/memorandums/export', :controller => 'memorandums', :action => 'export'
  map.export_accident_data '/job_accidents/export', :controller => 'job_accidents', :action => 'export'
  map.export_change_from_before '/people/export_change_from_before/:change_result', :controller => 'people', :action => 'export_change_from_before'
  map.person_not_schedule '/people/person_not_schedule', :controller => 'people', :action => 'person_not_schedule'

  map.resources :people do |person|
    person.resources :families, :collection => {:cancel_popup_detail => :get}
    person.resources :addresses, :collection => {:cancel_popup_detail => :get}
    person.new_experience '/new/:experience_type', :controller => 'experiences', :action => 'new', :conditions => {:method => :get }
    person.resources :experiences, :collection => {:cancel_popup_detail => :get}
    person.resources :educations, :collection => {:cancel_popup_detail => :get}
    person.resources :employments, :collection => {'popup_add_employment' => :get, :history_jabatan => :get, 'delete_work_contract' => :get, :cancel_popup_detail => :get, 'popup_terminasi' => :get, }
    person.resources :trainings, :collection => {:cancel_popup_detail => :get}
    person.resources :violations
    person.resources :accidents
    person.resources :awards
  end


  map.popup_history_status_pajak "popup_history_status_pajak/:id" ,:controller =>  "people", :action => "popup_history_status_pajak"
  map.reset_list_index "reset_list_index", :controller =>  "people", :action => "reset_list_index"
  map.reset_list_index "reset_list_index", :controller =>  "people", :action => "reset_list_index"
  map.reset_list_salaries "reset_list_salaries", :controller =>  "salaries", :action => "reset_list_salaries"
  map.reset_list_thr "reset_list_thr", :controller =>  "holiday_allowances", :action => "reset_list_thr"
  map.reset_list_mutasi "reset_list_mutasi", :controller =>  "people", :action => "reset_list_mutasi"
  map.reset_list_demosi "reset_list_demosi", :controller =>  "people", :action => "reset_list_demosi"
  map.reset_list_promotion "reset_list_promotion", :controller =>  "people", :action => "reset_list_promotion"

  map.riwayat_pendidikan "riwayat_pendidikan/:person_id", :controller => "people", :action => "riwayat_pendidikan"
  map.riwayat_experience "riwayat_experience/:person_id/:type", :controller => "people", :action => "riwayat_experience"

  map.popup_edit_experience "popup_edit_experience/:person_id/:id/:data_type", :controller => "experiences", :action => "popup_edit_experience"
  map.popup_add_experience "popup_add_experience/:person_id/:data_type", :controller => "experiences", :action => "popup_add_experience"
  map.popup_detail_employment "popup_detail_employment/:person_id/:id", :controller => "employments", :action => "popup_detail_employment"
  map.popup_add_pendidikan "popup_add_pendidikan/:person_id", :controller => "educations", :action => "popup_add_pendidikan"
  map.popup_edit_pendidikan "popup_edit_pendidikan/:person_id/:id", :controller => "educations", :action => "popup_edit_pendidikan"
  map.popup_add_family "popup_add_family/:person_id", :controller => "families", :action => "popup_add_family"
  map.popup_edit_family "popup_edit_family/:person_id/:id", :controller => "families", :action => "popup_edit_family"
  map.popup_add_address "popup_add_address/:person_id", :controller => "addresses", :action => "popup_add_address"
  map.popup_edit_address "popup_edit_address/:person_id/:id", :controller => "addresses", :action => "popup_edit_address"
  map.popup_add_training "popup_add_training/:person_id", :controller => "trainings", :action => "popup_add_training"
  map.popup_detail_training "popup_detail_training/:person_id/:id", :controller => "trainings", :action => "popup_detail_training"
  map.create_work_contract "/create_work_contract", :controller => "employments", :action => "create_work_contract"
  map.destroy_work_contract "/destroy_work_contract", :controller => "employments", :action => "destroy_work_contract"
  map.cancel_work_contract "/cancel_work_contract", :controller => "employments", :action => "cancel_work_contract"
  map.update_work_contract "/update_work_contract", :controller => "employments", :action => "update_work_contract"

  map.create_award "/create_award", :controller => "awards", :action => "create_award"
  map.cancel_award "/cancel_award", :controller => "awards", :action => "cancel_award"
  map.update_award '/update_award', :controller => 'awards', :action => 'update_award'
  map.destroy_award "/destroy_award", :controller => "awards", :action => "destroy_award"

  map.people_delete_multiple '/people/delete_multiple', :controller => 'people', :action => 'delete_multiple', :method => :post

  map.memorandums_delete_multiple '/memorandums/delete_multiple', :controller => 'memorandums', :action => 'delete_multiple', :method => :post
  map.job_accidents_delete_multiple '/job_accidents/delete_multiple', :controller => 'job_accidents', :action => 'delete_multiple', :method => :post
  map.addresses_delete_multiple '/addresses/delete_multiple', :controller => 'addresses', :action => 'delete_multiple', :method => :post
  map.families_delete_multiple '/families/delete_multiple', :controller => 'families', :action => 'delete_multiple', :method => :post
  map.trainings_delete_multiple '/trainings/delete_multiple', :controller => 'trainings', :action => 'delete_multiple', :method => :post
  map.violations_delete_multiple '/violations/delete_multiple', :controller => 'violations', :action => 'delete_multiple', :method => :post
  map.accidents_delete_multiple '/accidents/delete_multiple', :controller => 'accidents', :action => 'delete_multiple', :method => :post
  map.educations_delete_multiple '/educations/delete_multiple', :controller => 'educations', :action => 'delete_multiple', :method => :post
  map.experiences_delete_multiple '/experiences/delete_multiple', :controller => 'experiences', :action => 'delete_multiple', :method => :post
  map.settings_delete_multiple '/settings/delete_multiple', :controller => 'settings', :action => 'delete_multiple', :method => :post

  map.edit_emergency_contact '/edit_emergency_contact/:id', :controller => 'people', :action => 'edit_emergency_contact'
  map.update_emergency_contact '/update_emergency_contact/:id', :controller => 'people', :action => 'update_emergency_contact'

  map.ajax_people_city_of_birth '/ajax_people_city_of_birth', :controller => 'people', :action => 'ajax_people_city_of_birth'
  map.ajax_people_religion '/ajax_people_religion', :controller => 'people', :action => 'ajax_people_religion'
  map.ajax_people_ethnicity '/ajax_people_ethnicity', :controller => 'people', :action => 'ajax_people_ethnicity'

  map.ajax_experience_company_name '/ajax_experience_company_name', :controller => 'experiences', :action => 'ajax_experience_company_name'
  map.ajax_violation_person_in_charge_name '/ajax_violation_person_in_charge_name/:id', :controller => 'violations', :action => 'ajax_violation_person_in_charge_name'

  map.institution_address '/institution_address/:id', :controller => 'addresses', :action => "institution_address", :conditions => { :method => :get }

  map.ajax_accident_location_name '/ajax_accident_location_name', :controller => 'accidents', :action => 'ajax_accident_location_name'
  map.ajax_accident_category_name '/ajax_accident_category_name', :controller => 'accidents', :action => 'ajax_accident_category_name'
  map.ajax_person_trained_in_name '/ajax_training_person_trained_in/:id', :controller => 'trainings', :action => 'ajax_training_person_trained_in'
  map.get_person_by_javascript '/get_person_by_javascript/:id', :controller => 'people', :action => 'get_person_by_javascript'

  map.history '/history/:id', :controller => 'people', :action => 'history'

  # absences Routes
  map.absences_daily_index_table "/absences/daily_index_table", :controller => 'absences', :action => 'daily_index_table'
  map.absences_monthly_index_table "/absences/monthly_index_table", :controller => 'absences', :action => 'monthly_index_table'
  map.absences_late_table "/absences/late_table", :controller => 'absences', :action => 'late_table'
  map.absences_more_hour_table "/absences/more_hour_table", :controller => 'absences', :action => 'more_hour_table'
  map.absences_less_hour_table "/absences/less_hour_table", :controller => 'absences', :action => 'less_hour_table'
  map.absences_more_rest_table "/absences/more_rest_table", :controller => 'absences', :action => 'more_rest_table'
  map.absences_less_rest_table "/absences/less_rest_table", :controller => 'absences', :action => 'less_rest_table'
  map.absences_absent_table "/absences/absent_table", :controller => 'absences', :action => 'absent_table'
  map.absences_list_presence_report "/absences/list_presence_report", :controller => 'absences', :action => 'list_presence_report'
  map.absences_presence_report_table "/absences/presence_report_table", :controller => 'absences', :action => 'presence_report_table'
  map.absences_absence_report_table "/absences/absence_report_table", :controller => 'absences', :action => 'absence_report_table'
  map.absences_override_late "/absences/override_late", :controller => 'absences', :action => 'override_late', :conditions => { :method => :put }
  map.absences_override_popup "/absences/override_popup", :controller => 'absences', :action => 'override_popup'
  map.absences_more_hour_popup "/absences/more_hour_popup", :controller => 'absences', :action => 'more_hour_popup'
  map.absences_more_hour_action "/absences/more_hour_action", :controller => 'absences', :action => 'more_hour_action'
  map.absences_less_hour_popup "/absences/less_hour_popup", :controller => 'absences', :action => 'less_hour_popup'
  map.absences_less_hour_action "/absences/less_hour_action", :controller => 'absences', :action => 'less_hour_action'
  map.absences_more_rest_popup "/absences/more_rest_popup", :controller => 'absences', :action => 'more_rest_popup'
  map.absences_more_rest_action "/absences/more_rest_action", :controller => 'absences', :action => 'more_rest_action'
  map.absences_less_rest_action "/absences/less_rest_action", :controller => 'absences', :action => 'less_rest_action'
  map.absences_absent_popup "/absences/absent_popup", :controller => 'absences', :action => 'absent_popup'
  map.absences_absent_action "/absences/absent_action", :controller => 'absences', :action => 'absent_action'
  map.start_absence "/start_absence/:id", :controller => 'absences', :action => 'start_work'
  map.end_absence "/end_absence/:id", :controller => 'absences', :action => 'end_work'
  map.myabsence "/myabsence/:id", :controller => 'absences', :action => 'my_absence'
  map.my_monthly_absence_table "/my_monthly_absence_table", :controller => 'absences', :action => 'my_monthly_absence_table'
  map.my_monthly_absence "/my_monthly_absence/:id", :controller => 'absences', :action => 'my_monthly_absence'
  map.my_yearly_absence "/my_yearly_absence/:id", :controller => 'absences', :action => 'my_yearly_absence'
  map.absences_divisions_by_department "/absences/divisions_by_department", :controller => 'absences', :action => 'divisions_by_department'
  map.schedules_groups_by_division "/schedules/groups_by_division", :controller => 'schedules', :action => 'groups_by_division'

  map.namespace :api do |api|
    # api.resources :divisions
    # api.connect '/divisions/:token_string/:permalink/:hash_key/:id', :controller => 'divisions', :action => 'show'
    api.connect '/divisions/:company_id', :controller => 'divisions', :action => 'show'
    api.connect '/people/employee/:token_string/:permalink/:hash_key', :controller => 'people', :action => 'employee'
    api.connect '/people/position_name/:position_id/:token_string/:permalink/:hash_key', :controller => 'people', :action => 'position_name'
  end

  # company controller route
  map.resources :leaves, :collection =>{
    :leaves_table => :get,
    :get_employee => :get,
    :update_status => :post,
    :get_status => :get,
    :delete_multiple => :post,
    :update_employee_leave_quota => :post
  }, :member => {:update_employee_leave_quota => :put}
  map.resources :payrolls
  map.resources :allowances, :collection => {:show_allowance => :get}
  map.resources :companies
  map.resources :educational_institutions
  #map.resources :awards
  map.resources :holding_companies
  map.resources :overtimes, :collection => {
    :overtime_table => :get,
    :delete_multiple => :post,
    :overtime_data_create => :post,
    :index_done => :get,
    :update_status => :post,
    :overtime_data_table => :get,
    :overtime_report_table => :get,
    :overtime_report_export => :get,
    :export_overtime => :get
  }, :member =>{
    :overtime_data_update => :put
  }
  map.resources :salaries, :collection => {
    :get_employee => :get,
    :report => :get,
    :search => :get,
    :mine => :get,
    :export => :get,
    :informasi_gaji => :get,
    :edit_informasi_gaji => :get,
    :change_informasi_gaji => :put,
    :print_slip => :get
  },:member => {
    :print => :get,
    :generate => :post,
    :download => :get
  }
  map.resources :holiday_allowances, :collection => {
    :report => :get,
    :search => :get,
    :mine => :get,
    :export => :get
  },:member => {
    :print => :get,
    :generate => :post,
    :download => :get
  }

  map.resources :salary_master_datas, :collection => {
    :import => :post,
    :download_salary => :get,
    :history => :get
  }

  map.resources :absences, :collection => {
    :mine => :get,
    :presence_report => :get,
    :export_my_yearly_absence => :get,
    :export_my_absence => :get,
    :export_presence_report_xls => :get,
    :export_my_monthly_absence => :get,
    :export_absensi_kerja => :get,
    :export_late => :get,
    :export_more_hour => :get,
    :export_less_hour => :get,
    :export_more_rest => :get,
    :export_less_rest => :get,
    :export_absent => :get,
    :export_no_logout => :get,
    :employee_present => :post,
    :no_logout => :get,
    :no_logout_table => :get,
    :no_logout_popup => :get,
    :no_logout_action => :post,
    :fingerprint_data_import => :get,
    :redeem_leaves => :post,
    :fix_presences => :get,
    :delete_presences => :post,
    :remove_presence => :get,
    :popup_absent_to_people => :get,
    :popup_import_data_absent => :get,
    :import => :post
    
  }
  map.resources :job_accidents,:collection => {:get_data_person_in_autocomplete => :get}
  map.resources :memorandums
  map.resources :settings, :collection => {
    :new_cuti_sakit => :get,
    :create_cuti_sakit => :post,
    :edit_cuti_sakit => :get
  }, :member => {
    :update_cuti_sakit => :put
  }

  map.resources :fingerprint_settings,
    :collection => {
    :delete_multiple => :post,
    :delete_device_data => :post
  }

  map.resources :shifts, :collection => {
    :delete_multiple => :post
  }
  map.resources :holidays , :collection => {
    :delete_multiple => :post
  }
  map.resources :job_times
  map.resources :promotions
  map.resources :schedules
  map.resources :dashboard, :collection => {
    :find_statistik_get => :get,
    :page_chart=> :get,
    :content_others=> :get,
    :view_rekap_lembur=> :get,
    :show_statistik_page => :get,
    :get_status_table=>:get,
    :get_accident_table=>:get,
    :get_sp_table=>:get,
    :get_mutasi_table=>:get,
    :get_formasi_table=>:get,
    :get_absensi_table=>:get,
    :view_absensi => :get,
    :view_laporan_ketidakhadiran => :get,
    :view_rekap_absensi => :get,
    :view_rekap_overtime => :get,
    :view_formasi => :get,
    :view_formasi_jabatan => :get,
    :view_formasi_departemen => :get,
    :view_formasi_bagian => :get,
    :view_mutasi => :get,
    :view_status => :get,
    :view_sp => :get,
    :view_accident => :get
  }
  map.resources :imports, :collection => {
    :create_import => :post,
    :create_for_absent => :post
  }

  map.namespace :organization_structure do |organization|
    organization.resources :work_groups, :collection => { :delete_multiple => :post}
    organization.resources :divisions, :collection => { :delete_multiple => :post}
    organization.resources :departments, :collection => { :delete_multiple => :post}
    organization.resources :positions, :collection => { :delete_multiple => :post}
    organization.departments_table "/departments_table", :controller => 'departments', :action => 'table'
    organization.divisions_table "/divisions_table", :controller => 'divisions', :action => 'table'
    organization.groups_table "/groups_table", :controller => 'work_groups', :action => 'table'
    organization.positions_table "/positions_table", :controller => 'positions', :action => 'table'
    organization.update_divisions_list "/groups_update_divisions_list/:id", :controller => 'work_groups', :action => 'update_divisions_list'
  end

  map.person_table "/person_table", :controller => 'people', :action => 'table'
  map.people_change_jabatan "/people_change_jabatan/:id", :controller => 'people', :action => 'change_jabatan'

  map.upload_people_photo "/people/upload_people_photo", :controller => 'people', :action => 'upload_people_photo'

  map.people_print_employee_id_card 'people/print_card/:id', :controller => 'people', :action => 'print_card'
  map.keluar_masuk "/keluar_masuk", :controller => 'people', :action => 'keluar_masuk'
  map.list_mutasi "/list_mutasi", :controller => 'people', :action => 'list_mutasi'
  map.list_demosi "/list_demosi", :controller => 'people', :action => 'list_demosi'

  map.myovertime "/myovertime/:id", :controller => 'people', :action => 'my_overtime'
  map.cuti_sakit "/cuti_sakit", :controller => 'settings', :action => 'cuti_sakit'
  map.list_jumlah_group "/list_jumlah_group/:id", :controller => 'divisions', :action => 'list_jumlah_group'

  map.download_data "/download_data", :controller => 'absences', :action => 'download_data'
  map.download_from_device "/download_from_device", :controller => 'absences', :action => 'download_from_device'
  map.late "/late", :controller => 'absences', :action => 'late'
  map.more_hour "/more_hour", :controller => 'absences', :action => 'more_hour'
  map.less_hour "/less_hour", :controller => 'absences', :action => 'less_hour'
  map.more_rest "/more_rest", :controller => 'absences', :action => 'more_rest'
  map.less_rest "/less_rest", :controller => 'absences', :action => 'less_rest'

  map.data_karyawan "/data_karyawan/:company_id", :controller => "people", :action => "data_karyawan"
  map.save_user_data_karyawan "/save_user_data_karyawan", :controller => "people", :action => "save_user_data_karyawan"

  map.absent "/absent", :controller => 'absences', :action => 'absent'
  map.new_absent "/absent/new", :controller => 'absences', :action => 'new_absent'
  #  map.new_cuti_sakit "/cuti_sakit/new", :controller => 'settings', :action => 'new_cuti_sakit'
  #  map.create_cuti_sakit "/cuti_sakit/newx", :controller =>'settings', :action => 'create_cuti_sakit'

  map.shift_karyawan "/shift_karyawan/:id", :controller => 'shifts', :action => 'shift_karyawan'

  map.layout_schedule "/layout_schedule", :controller => 'schedules', :action => 'layout_schedule'
  map.create_import "/create_import", :controller => "import", :action => "create_import"

  # map.slip "/salaries/slip/:nama", :controller => 'salaries', :action => 'slip'
  map.logout_by_checkloginstatus "/logout_by_checkloginstatus", :controller => 'people', :action => 'checkloginstatus'
  map.howto "/howto", :controller => 'dashboard', :action => 'get_howto'
  map.division_form_for_employment 'division_form_for_employment/:division_id', :controller => 'divisions', :action => 'division_form_for_employment'
  map.change_divisi "/change_divisi/:id", :controller => 'employments', :action => 'change_divisi'
  map.change_divisi_filter "/change_divisi_filter/:id", :controller => 'salaries', :action => 'change_divisi_filter'
  map.change_people_divisi "/change_people_divisi/:id", :controller => 'people', :action => 'change_people_divisi'
  map.cancel "cancel", :controller => 'employments', :action => 'cancel'
  map.change_group "/change_group/:id", :controller => 'employments', :action => 'change_group'
  map.change_city "/change_city/:province_name", :controller => 'addresses', :action => 'change_city'
  map.edit_health "/edit_health/:id", :controller => 'people', :action => 'edit_health'
  map.resources :imports
	map.import_proc '/import/proc/:id', :controller => "imports", :action => "proc_csv"

  map.company_callback '/a/:permalink', :controller => 'user_sessions', :action => 'new'
  map.connect '/user_sessions/callback/:permalink', :controller => 'user_sessions', :action => 'callback'
  map.connect '/user_sessions/callback/a/:permalink', :controller => 'user_sessions', :action => 'callback'

end

