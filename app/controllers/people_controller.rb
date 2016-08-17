class PeopleController < ApplicationController
  add_breadcrumb "Karyawan", "#person_index"
  helper_method :sort_column, :sort_direction
  before_filter :login_required, :except => ["data_karyawan","save_user_data_karyawan"]
  skip_filter :authenticate, :only => ["data_karyawan","save_user_data_karyawan"]
  skip_before_filter :verify_authenticity_token, :only => ["save_user_data_karyawan"]
  require 'gchart'
  before_filter :prepare_holding, :only => ["new", "create", "edit", "update"]
  before_filter :prepare_autocomplete_data, :only => ["new", "create", "edit", "update"]
  before_filter :prepare_person_person, :only => ["mutasi","my_absence","my_salary",
    "my_overtime","formasi","status"]
  before_filter :prepare_keluar_masuk, :only => "keluar_masuk"
  before_filter :prepare_demosi, :only => ["list_demosi","reset_list_demosi"]
  before_filter :prepare_mutasi, :only => ["list_mutasi","reset_list_mutasi"]
  before_filter :prepare_promotions, :only => ["reset_list_promotion"]
  before_filter :prepare_index, :only => ["reset_list_promotion"]

  before_filter :show, :only => ["edit_emergency_contact"]
  before_filter :count_people, :only => [:keluar_masuk, :delete_multiple]

  ssl_required :reset_list_index, :reset_list_mutasi, :reset_list_demosi, :reset_list_promotion, :list_mutasi, :change_people_divisi, :upload_people_photo,
    :riwayat_pendidikan, :riwayat_experience, :print_card, :edit_health, :edit_emergency_contact, :update_emergency_contact, :delete_multiple, :popup_history_status_pajak,
    :data_karyawan, :save_user_data_karyawan, :checkloginstatus, :change_jabatan, :export, :history, :keluar_masuk, :export_change_from_before, :list_demosi, :my_overtime,
    :formasi, :status, :get_person_by_javascript 

  before_filter :current_features, :except => ["data_karyawan","save_user_data_karyawan"]
  before_filter :check_features, :only => [:index, :export, :new, :edit, :delete_multiple, :show, :multiple_user, :mutasi, :formasi, :status]
  # Check features accessability by user roles
  #layout = false
  def check_features
    case params[:action]
    when "index"
      current_features.include?('employee_index') ? true : invalid_features
    when "export"
      current_features.include?('employee_export') ? true : invalid_features
    when "new"
      current_features.include?('employee_new') ? true : invalid_features
    when "edit"
      current_features.include?('employee_edit') ? true : invalid_features
    when "delete_multiple"
      current_features.include?('employee_delete') ? true : invalid_features
    when "show"
      current_features.include?('employee_detail') ? true : invalid_features
    when "multiple_user"
      current_features.include?('employee_user') ? true : invalid_features
      # Mutasi
    when "mutasi"
      current_features.include?('mutation_index') ? true : invalid_features
      # Formasi
    when "formasi"
      current_features.include?('formation_index') ? true : invalid_features
      # Status
    when "status"
      current_features.include?('status_index') ? true : invalid_features
    end
    # return true
  end

  def index
    add_breadcrumb "Daftar karyawan", "#person_index"
    session[:url_act] = "person_index"
    prepare_index
    if params[:filter].blank?
      reload_page('div_list_persons','list_persons')
    else
      reload_page('div_list_persons','list_persons','person_index','ada')
    end
  end

  def show
    
    @person = Person.by_company(current_company_id).find(params[:id])    
    prepare_show
    render :layout => false
  end

  def new
    add_breadcrumb "Daftar karyawan", "#person_index"
    add_breadcrumb "Tambah karyawan", "#person_new"
    @person = Person.new
    @tax = TaxStatus.all(:conditions => "company_id=#{current_company_id}", :order => :id)
    render :layout => false
  end

  def create
    session[:url_act_msg] = "create"
    unless params[:person].blank?
      param = (params[:person]).merge(:company_id => current_company_id)
      @person = Person.new(param)
      if @person.save
        create_employment(param)
        @person.create_history_status_pajak
        @import = Import.new
        prepare_index
        redirect_to "/a/#{current_permalink}#person_index?tab=is_simpan"
      else
        session[:params] = get_param_for_session
        session[:message] = @person.errors.full_messages
        flash[:notice] = "Data karyawan gagal disimpan"
        redirect_to "/a/#{current_permalink}#person_new"
      end
    end
  end

  def edit
    @person = Person.by_company(current_company_id).find(params[:id])
    add_breadcrumb "Daftar karyawan", "#person_index"
    add_breadcrumb "Detail karyawan", "#people/#{@person.id}?tab=0"
    add_breadcrumb "Edit karyawan", "#people/#{@person.id}/edit"
    @address = Address.new
    @addresses = @person.addresses
    @families = @person.families
    @tax = TaxStatus.all(:conditions => "company_id=#{current_company_id}", :order => :id)
    render :layout => false
  end

  def update
    prepare_unormal_eyes   
    param = Person.param_date_to_str(params[:person])
    @person = Person.by_company(current_company_id).find(params[:id])
    @address = Address.new

    @person.fingerprint_user = params[:person][:fingerprint_user].to_i unless params[:person][:fingerprint_user].blank?

    if @person.update_attributes(params[:person])
      @person.create_history_status_pajak
      prepare_show
      if (param[:tab_name]=="kesehatan")
        flash.now[:notice] = "Data kesehatan karyawan berhasil diupdate"
        reload_page_edit_health('div_show','show',"people/#{@person.id}?tab=3",'no_reload')
      elsif (param[:tab_name]=="kontak_darurat")
        flash.now[:notice] = "Kontak darurat karyawan berhasil diupdate"
        reload_page_edit_contact('div_show','show',"people/#{@person.id}?tab=4",'no_reload')
      elsif (param[:tab_name]=="absen")
        render :nothing => :true, :status => 200
      else
        flash[:notice] = "Data karyawan berhasil diupdate"
        redirect_to "/a/#{current_permalink}#people/#{@person.id}?tab=0"
      end
    else
      prepare_show
      load_attributes_is_failed
    end
  end

  def person_not_schedule
    add_breadcrumb "Karyawan Tanpa Schedule", "#person_not_schedule"
    @per_page = 10
    @people = HrSetting.person_not_schedule(current_company_id, params[:page])
    reload_page("div_list_persons", "person_not_schedule","person_not_schedule")
  end

  def reset_list_index
    session[:url_act] = "index"    
    reload_page('div_list_persons','list_persons')
  end

  def reset_list_mutasi
    reload_page('div_list_mutasi', 'list_mutasi')
  end

  def reset_list_demosi
    reload_page('div_list_demosi', 'list_demosi')
  end

  def reset_list_promotion    
    reload_page('div_list_promotions', 'promotions/list_promotions')
  end

  def list_mutasi
    session[:url_act] = "list_mutasi"
    reload_page('div_list_mutasi', 'list_mutasi',nil, "stop_filter")
  end

  def change_people_divisi
    @divisions = params[:id].blank?? Division.by_company(current_company_id).all :
      Division.by_company(current_company_id).all(:conditions=> "department_id=#{params[:id]}")
    render :update do |page|
      page.replace_html 'div_divisi', :partial=> 'divisi_data'
      page << "$('#div_divisi').show()"
      page << "$('#person_division_name').attr('disabled','disabled');" if params[:id].blank?
    end
  end

  def upload_people_photo
    responds_to_parent do
      render :update do |page|
      end
    end
  end

  def riwayat_pendidikan
    @person = Person.by_company(current_company_id).find(params[:person_id])
    render :layout => false
  end

  def riwayat_experience
    @person = Person.by_company(current_company_id).find(params[:person_id])
    @type = params[:type]
    @experiences = @person.exp_by_type(@type)
    render :layout => false
  end

  def print_card
    person = Person.by_company(current_company_id).find(params[:id])
    @company = person.holding_company.name
    render :layout => "/people/print_card.html.erb"
  end

  def edit_health
    add_breadcrumb "Daftar karyawan", "#person_index"
    add_breadcrumb "Detail karyawan", "#people/#{params[:id]}?tab=0"
    add_breadcrumb "Edit kesehatan", "#edit_health/#{params[:id]}"
    @person = Person.find(params[:id])
    @upset = @person.left_minus > 0 && @person.right_minus > 0  && @person.left_plus > 0 && @person.right_plus > 0  && @person.left_silinder > 0 && @person.right_silinder > 0 
    if @upset == true
      @is_upset == "ya"
    else   
      @is_upset == "tidak"
    end 
    render :layout => false

  end

  def edit_emergency_contact
    @person = Person.by_company(current_company_id).find(params[:id])
    render :layout => "application2"
  end

  def update_emergency_contact
    @person = Person.by_company(current_company_id).find(params[:id])
    if @person.update_attributes(params[:person])
      flash.now[:notice] = "Karyawan berhasil diubah!"
      redirect_to person_path(@person) + '?tab=4'
    else
      @thm = Person.find(params[:id])
      flash.now[:notice] = "Karyawan tidak berhasil diubah!"
      render :action => :edit
    end
  end

  def delete_multiple
    params[:sort]= "employee_identification_number" if params[:sort] == "NIK"
    params[:sort]= "firstname" if params[:sort] == "nama"
    flash.now[:notice] = "Data karyawan gagal dihapus"
    unless params[:ids].blank?
      delete_proceses
      @import = Import.new
      flash.now[:notice] = "Data karyawan berhasil dihapus"
    end
    @per_page = 10
    session[:url_act] = params[:act_name]
    if params[:act_name]=="list_mutasi"
      prepare_mutasi
      reload_page('div_mutasi','mutasi')
    elsif params[:act_name]=="keluar_masuk"
      prepare_keluar_masuk
      reload_page('div_keluar_masuk','keluar_masuk')
    elsif params[:act_name]=="promotions"
      prepare_promotions
      reload_page('div_promotions','promotions/promotions')
    elsif params[:act_name]=="list_demosi"
      prepare_demosi
      reload_page('div_demosi','demosi')
    else      
      prepare_index
      reload_page('div_index','index')
    end    
  end

  def popup_history_status_pajak
    @person = Person.by_company(current_company_id).find(params[:id])
    render :layout => false
  end

  def data_karyawan
    unless params[:company_id].blank?
      @people = Person.by_company(params[:company_id]).all(:select => "firstname,lastname, id, personal_email")
      data = []
      @people.each do |p|
        data << [p.firstname, p.lastname, p.personal_email.blank? ? "" : p.personal_email, p.id]
      end
      render :json => data
    end
  end

  def save_user_data_karyawan
    #puser_token = {"password_confirmation"=>"2107917a481a6880fba3dd1f9970ad39d3e00cbc", "id"=>nil, :token_string=>"glavekngdyersdndylixhczlyzfsjukcmejkngpq", "last_name"=>"Lela", "company_id"=>1, "first_name"=>"Nur", "email"=>"nurlela@nurlela.com"}
    puser = ActiveSupport::JSON.decode(params[:user])
    puser_token = puser.merge('token_string'=> params[:token_string])

    if Person.get_user_and_karyawan(puser_token)
      render :json => "sukses"
    else
      render :json => "gagal"
    end
  end

  def checkloginstatus
    # require "net/http"
    # require "uri"
    # uri = URI.parse("#{ApplicationController::APPSCHEF_URL}/api/users/already_logged_out/#{session[:user_log_id]}")
    # emp = Net::HTTP.get(uri)
    # a = ActiveSupport::JSON.decode(p)
    # render :text => a['already_logged_out']
    # /api/users/:user_log_id/update_active_time

    require 'net/https'
    url = URI.parse("#{ApplicationController::APPSCHEF_URL}/api/users/#{session[:user_log_id]}/update_active_time")
    if RAILS_ENV == "development" && PROTOCOL_STRING != "https://"
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
    else
      req = Net::HTTP.new(url.host, url.port)
      req.use_ssl = true
      req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http = Net::HTTP::Get.new(url.request_uri)
      res = req.request(http)
    end
    a = ActiveSupport::JSON.decode(res.body)
    render :text => a['return_value']
  end

  def change_jabatan
    @positions = Position.by_company(current_company_id).all(:conditions=> "division_id=#{params[:id]}")
    render :update do |page|
      page.replace_html 'div_jabatan', :partial=> 'people_change_jabatan'
    end
  end

  def export
    @export_data = Person.by_company(current_company_id).all(:include => [:employments], :conditions => session[:conditions], :order => current_sort)
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Karyawan"
    format = Spreadsheet::Format.new :weight => :bold, :border=> 4
    format2 = Spreadsheet::Format.new :border=> 2
    set_layout_sheet(data_sheet, format)
    header = ['NIK','Nama Karyawan','Jenis Kelamin','Tanggal Lahir','Agama','Tanggal Diterima','Habis Kontrak',
      'Department','Bagian','Shift','No KTP','Alamat','Pendidikan','Golongan Darah',
      'Status Kerja Karyawan','No Jamsostek','No Rekening','Id Fingerpring','Status Pajak']
    data_sheet.row(0).replace header 
    @export_data.each_with_index do |p, index|      
      emp = p.current_employment
      kontrak = p.work_contracts.collect{|x| x if x.id==p.latest_work_contract_id}.compact.first
      id_fingerprint = p.fingerprint_user
      a = index+1
      set_layout_sheet(data_sheet, format2, a)      
      data_sheet.row(a).replace [ p.employee_identification_number, p.full_name, p.gender, (p.birth_date.strftime('%d/%m/%Y') unless p.birth_date.blank?),
        p.religion,p.employments.blank? ? "" : p.employments.first.employment_start.strftime('%d/%m/%Y'),
        kontrak.blank? ? "" : kontrak.contract_end.blank? ? "" : kontrak.contract_end.strftime('%d/%m/%Y'),
        emp.blank? ? "" : emp.department.blank? ? "" : emp.department.department_name,
        emp.blank? ? "" : emp.division.blank? ? "" : emp.division.name,
        get_shift(p), p.no_ktp,
        Address.last_person_address(p),p.educations.blank? ? "" : p.educations.last.pendidikan_terakhir ,
        p.blood_type,
        kontrak.blank? ? "" : kontrak.contract_type.contract_type_name , p.jamsostek_number,p.account_number,
        id_fingerprint.blank? ? " " : id_fingerprint,
        p.tax_status.blank? ? "" : p.tax_status.tax_status_code ]
    end
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "karyawan.xls", :type =>  "application/vnd.ms-excel"
  end


  def history    
    @person = Person.by_company(current_company_id).find(params[:id])
    add_breadcrumb "Karyawan", "#person_index"
    add_breadcrumb "Daftar karyawan", "#person_index"
    add_breadcrumb "Riwayat Karyawan", "#people/#{@person.id}/employments?tab=0"
    @education = Education.new
    @type = params[:experience_type]
    @experience = Experience.new
    @experiences = @person.experiences
    @experience.experience_type = @type
    @award = Award.new
    @opened_tab = opened_tab(@type)
    render :layout => false
  end

  def keluar_masuk    
    add_breadcrumb "Keluar Masuk karyawan", "#keluar_masuk"
    reload_page('div_keluar_masuk', 'keluar_masuk', nil, 'stop')
  end

  def export_change_from_before    
    if params[:change_result] == "keluar_masuk"
      @export_data = Person.by_company(current_company_id).all(:include=> [:employments], :conditions => current_conditions, :order => current_sort)
      proses_export_keluar_masuk_change_from_before
    else
      if params[:change_result] == "demosi" || params[:change_result] == "mutasi" || params[:change_result] == "promosi"
        @export_data = Employment.all(:include=> [:person], :conditions => current_conditions, :order => current_sort)
        proses_export_change_from_before
      end
    end
  end

  def list_demosi
    add_breadcrumb "Karyawan", "#person_index"
    add_breadcrumb "Demosi karyawan", "#list_demosi"
    session[:url_act] = "list_demosi"
    prepare_demosi
    reload_page('div_list_demosi', 'list_demosi', nil, "stop_filter")
  end

  def my_overtime
    render :layout => false
  end

  def formasi
    gender_chart = Gchart.pie(:title => "Jenis Kelamin",
      :data => [80,20],
      :labels => ["80%","20%"],
      :size => '240x150',
      :max_value => 100
    )
    @gender_chart = "#{gender_chart}&chdl=Laki-laki|Perempuan"

    dept_chart = Gchart.pie(:title => "Department",
      :data => [40,10,20,30],
      :labels => ["40%","10%","20%","30%"],
      :size => '240x150',
      :max_value => 100
    )
    @dept_chart = "#{dept_chart}&chdl=Spinning|Weaving|Dyeing|Finishing"

    jab_chart = Gchart.pie(:title => "Jabatan",
      :data => [90,10],
      :labels => ["90%","10%"],
      :size => '240x150',
      :max_value => 100
    )
    @jab_chart = "#{jab_chart}&chdl=Buruh|Staff"

    render :layout => false
  end

  def status
    status_chart = Gchart.pie(:title => "Status Karyawan",
      :data => [70,30],
      :labels => ["70%","30%"],
      :size => '500x268',
      :max_value => 100
    )
    @status_chart = "#{status_chart}&chdl=Kontrak|Tetap"
    render :layout => false
  end

  def get_person_by_javascript
    person = Person.find(params[:id])
    emp = person.current_employment
    group_name = ""
    group_name = emp.work_group.blank? ? "" : emp.work_group.work_group_name unless emp.blank?
    render :update do |page|
      page << "get_row_data(#{person.id},'#{person.full_name}','#{group_name}')"
    end
  end

  private

  def create_employment(param)
    obj_emp = Employment.create(:person_id => @person.id, :position_id => param["position_name"],
      :employment_start => param["employment_date"],
      :department_id => param['department_name'],
      :work_division_id => param['division_name'],
      :change_from_before => "masuk kerja")
    obj_emp.save
    @person.update_attribute(:latest_employment_id, obj_emp.id)
  end

  def load_attributes_is_failed
    error_messages = ""
    @person.errors.each do |key, val|
      error_messages = "#{error_messages}, #{val}"
    end
    flash[:notice] = "Penyimpanan Data Gagal #{error_messages}"
    if (params[:person][:tab_name]=="kesehatan")
      @thm = Person.find(params[:id])
      reload_page('div_edit','edit')
    elsif params[:person][:tab_name]=="kontak_darurat"
      render :update do |page|
        page.replace_html "kontak_darurat", :partial=>"emergencies/emergency_info"
      end
    elsif params[:person][:tab_name]=="absen"
      redirect_to "/a/#{current_permalink}#absences/mine?id=#{@person.id}&profiles=1"
    else
      message = @person.errors.full_messages
      session[:params] = get_param_for_session
      session[:message] = message
      redirect_to "/a/#{current_permalink}#people/#{@person.id}/edit"
    end
  end

  def get_param_for_session
    param = params[:person]
    param.delete("headshot") if param.has_key?("headshot")
    param.delete("npwp") if param.has_key?("npwp")
    param.delete("ktp") if param.has_key?("ktp")
    param.delete("resume") if param.has_key?("resume")
    return param
  end

  def prepare_promotions
    params[:sort]= "firstname" if params[:sort] == "nama"
    str_by_company =  " AND people.company_id=#{current_company_id}"
    if params[:filter].blank?
      session[:conditions] = Person.with_promotion + str_by_company
    else
      session[:conditions] = Person.with_promotion(params[:filter]) + str_by_company
    end
    set_data_list_employment
  end

  def prepare_mutasi
    add_breadcrumb "Karyawan", "#person_index"
    add_breadcrumb "Mutasi karyawan", "#list_mutasi"
    params[:sort]= "people.firstname" if params[:sort] == "nama"
    str_by_company =  " AND people.company_id=#{current_company_id}"
    if params[:filter].blank?
      session[:conditions] = Person.with_mutasi + str_by_company
    else
      session[:conditions] = Person.with_mutasi(params[:filter]) + str_by_company
    end
    set_data_list_employment
  end

  def prepare_demosi    
    params[:sort]= "people.firstname" if params[:sort] == "nama"
    str_by_company =  " AND people.company_id=#{current_company_id}"
    if params[:filter].blank?
      session[:conditions] = Person.with_demosi + str_by_company
    else
      session[:conditions] = Person.with_demosi(params[:filter]) + str_by_company
    end
    set_data_list_employment
  end

  def prepare_index
    params[:sort]= "people.employee_identification_number" if params[:sort] == "NIK"
    params[:sort]= "people.firstname" if params[:sort] == "nama"
    str_by_company =  " AND people.company_id=#{current_company_id}"
    @import = Import.new    
    if params[:filter].blank?
      conditions = Person.without_keluar_masuk + str_by_company
      conditions << " AND employments.position_id=#{params[:position]}" if params[:position]
      conditions << " AND employments.department_id=#{params[:department]}" if params[:department]
      conditions << " AND employments.work_division_id=#{params[:division]}" if params[:division]
      conditions << " AND employments.work_group_id=#{params[:group]}" if params[:group]
      conditions << str_by_company
      session[:conditions] = conditions
    else
      session[:conditions]  = Person.without_keluar_masuk(params[:filter]) + str_by_company
    end
    set_data_list_person
  end

  def prepare_keluar_masuk
    session[:url_act] = "keluar_masuk"
    params[:sort]= "nama" if params[:sort] == "firstname"
    str_by_company =  " AND people.company_id=#{current_company_id}"
    if params[:filter].blank?
      session[:conditions] = Person.with_keluar_masuk + str_by_company
    else
      session[:conditions] = Person.with_keluar_masuk(params[:filter]) + str_by_company
    end
    set_data_list_person
  end


  def set_data_list_person
    session[:sort] = sort_column + " " + sort_direction
    @per_page = 50
    @people = Person.paginate(:page => params[:page], :per_page => @per_page, :include=> [:employments], :conditions => current_conditions, :order => current_sort)
  end

  def set_data_list_employment
    session[:sort] = sort_column + " " + sort_direction + ",employments.id ASC"
    @per_page = 10
    @employments = Employment.paginate(:include=> [:person],:page => params[:page], :per_page => @per_page, :conditions => current_conditions, :order => current_sort)
  end

  def prepare_show
    @import = Import.new
    @is_user_login = false
    unless current_user.person.blank?
      @is_user_login = params[:id].to_i == current_user.person.id && !params[:view_only].blank?
    end
    @experiences = @person.exp_by_type('work')
    @families = @person.families
    @accidents = Accident.find(:all, :conditions=>{:person_id=>[@person.id]}, :order => 'accident_date DESC') # person.accidents
    @awards = @person.awards
    @family = Family.new
    @family.address = Address.new
    @address = @family.address
    
   
  end

  def get_shift(p)
    shift = ""
    p.employee_shifts.each do |u|
      shift = u.shift.shift_name if u.is_active && !u.shift.blank?
    end
    #p.employee_shifts.collect{|u| u.shift.shift_name if u.is_active && !u.shift.blank?}  unless p.employee_shifts.blank?
    return shift
  end

  def sort_column
    Person.column_names.include?(params[:sort]) ? params[:sort] : "people.firstname"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def set_layout_sheet(data_sheet, format, colom = 0)
    for i in (0..16)
      data_sheet.row(colom).set_format(i, format);
    end
  end

  def delete_proceses
    if params[:act_name]=="list_mutasi" || params[:act_name]=="list_demosi" || params[:act_name]=="promotions"
      data = Employment.find(params[:ids])
      data.each do |p|
        p.set_previus_employment
        p.destroy
      end
    else
      data = Person.find(params[:ids])
      data.each do |p|
        if p.company_id == current_company_id
          p.destroy
        end
      end
    end
  end

  def proses_export_keluar_masuk_change_from_before
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "#{params[:change_result]}"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Nama','Bagian','Group','Jabatan','Jenis Kelamin','Tanggal Masuk','Tanggal Keluar', 'Masa Kerja','Status']
    @export_data.each_with_index do |p, index|
      emp = p.current_employment
      data_sheet.row(index+1).replace [ p.full_name,
        emp.blank? ? "" : emp.division.blank? ? "-" : emp.division.name,
        emp.blank? ? "" : emp.work_group.blank? ? "-" : emp.work_group.work_group_name,
        emp.blank? ? "" : emp.position.blank? ? "-" : emp.position.position_name,
        p.gender, p.employment_date,
        emp.blank? ? "" : emp.change_from_before == "terminasi" ? emp.employment_end : "",
        Person.second_to_days1(p.total_length_of_service(p)),
        p.current_status.blank? ? "" : p.current_status.contract_type.blank? ? "" : p.current_status.contract_type.contract_type_name]
    end

    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "#{params[:change_result]}.xls", :type =>  "application/vnd.ms-excel"
  end

  def proses_export_change_from_before
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "#{params[:change_result]}"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format

    data_sheet.row(0).replace [ 'Nama', 'Awal Departmen', 'Awal Bagian Kerja', 'Awal Jabatan',
      'Prosess', 'Tanggal', 'Departmen kerja baru', 'Bagian kerja baru',
      'Jabatan baru', 'Alasan']
    @export_data.each_with_index do |emp, index|
      emp_previous = Employment.find_by_id(emp.previous_employment_id)
      data_sheet.row(index+1).replace [ emp.person.full_name,
        emp_previous.blank? ? "" : emp_previous.department.blank? ? "-" : emp_previous.department.department_name,
        emp_previous.blank? ? "" : emp_previous.division.blank? ? "-" : emp_previous.division.name,
        emp_previous.blank? ? "" : emp_previous.position.blank? ? "-" : emp_previous.position.position_name,
        emp.updated_at, "",
        emp.blank? ? "" : emp.department.blank? ? "-" : emp.department.department_name,
        emp.blank? ? "" : emp.division.blank? ? "-" : emp.division.name,
        emp.blank? ? "" : emp.position.blank? ? "-" : emp.position.position_name,
        emp.reason_for_change ]
    end

    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "#{params[:change_result]}.xls", :type =>  "application/vnd.ms-excel"
  end

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name
          page.replace_html "notification", :partial=> "layouts/shared/notification" if HrSetting.is_notification_action(params)
          page << "stop_filter()" unless stop_filter.blank?
          #page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')"  unless flash.now[:notice].blank?
          page << "parent.$.fn.colorbox.close();"
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def reload_page_edit_health(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name
          page << "stop_filter()" if stop_filter.blank?
          page << "$('#info_kesehatan, #kontak_darurat, #info_perawatan, #data_keluarga,#info_pribadi,#info_alamat').hide();"
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('#info_kesehatan').show();"
          page << "$('#arrow4').removeClass('icons arrow_ico');"
          page << "$('#arrow4').addClass('icons drop_arrow_ico');"
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def reload_page_edit_contact(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name
          page << "stop_filter()" if stop_filter.blank?
          page << "$('#info_kesehatan, #kontak_darurat, #info_perawatan, #data_keluarga,#info_pribadi,#info_alamat').hide();"
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('#kontak_darurat').show();"
          page << "$('#arrow5').removeClass('icons arrow_ico');"
          page << "$('#arrow5').addClass('icons drop_arrow_ico');"
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def prepare_person_person
    conditions = ["employment_end IS NULL"]
    joins = [:employments]
    status = params[:status]
    unless status.blank?
      conditions << "employment_type = '#{status} and company_id = #{current_company_id}'"
    else
      conditions, joins = [], []
    end
    @people = Person.find(:all, :conditions => conditions.join(' AND ') , :joins => joins, :order => "created_at DESC, firstname ASC").paginate(:per_page => 50, :page => params[:page]) #unless @role.blank?
    @import = Import.new
  end

  def opened_tab(text)
    case text
    when 'work'
      '2'
    when 'organizational'
      '3'
    when 'training'
      '4'
    end
  end

  def prepare_holding
    @holdings = HoldingCompany.all
  end

  def prepare_autocomplete_data
    @cities = Person.find(:all, :conditions => { :company_id => current_company_id }, :select => 'DISTINCT city_of_birth').map{|m| m.city_of_birth}.join(',')
    @ethnicities = Person.find(:all, :conditions => { :company_id => current_company_id }, :select => 'DISTINCT ethnicity').map{|m| m.ethnicity}.join(',')
    @religions = Person.find(:all, :conditions => { :company_id => current_company_id }, :select => 'DISTINCT religion').map{|m| m.religion}.join(',')
  end

  def count_people
    emp_cond = "(employments.change_from_before='masuk kerja' OR employments.change_from_before='terminasi') AND people.company_id =#{current_company_id}"
    @people_count = Person.count(:include => [:employments], :conditions => emp_cond)
  end

  def prepare_unormal_eyes
    params[:person][:left_minus] = 0 if params[:person][:is_left_minus] != "on" &&  !params[:person][:is_left_minus].nil?
    params[:person][:right_minus]= 0 if params[:person][:is_right_minus] != "on" &&  !params[:person][:is_right_minus].nil?
    params[:person][:left_plus]= 0 if params[:person][:is_left_plus] != "on" &&  !params[:person][:is_left_plus].nil?
    params[:person][:right_plus]= 0 if params[:person][:is_right_plus] != "on"  && !params[:person][:is_right_plus].nil?
    params[:person][:left_silinder]= 0 if params[:person][:is_left_silinder] != "on" &&  !params[:person][:is_left_silinder].nil?
    params[:person][:right_silinder]= 0 if params[:person][:is_right_silinder] != "on" &&  !params[:person][:is_right_silinder].nil?
  end  

end

