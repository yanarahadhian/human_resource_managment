class SalariesController < ApplicationController
  # before_filter :login_required
  before_filter :determine_date, :only => [:index, :mine, :reset_list_salaries]
  before_filter :determine_date_now, :only => [:reset_list_salaries]
  before_filter :prepare_index, :only => [:index]

  layout "application2"

  ssl_required :check_features, :reset_list_salaries, :mine, :get_employee, :informasi_gaji, :edit_informasi_gaji,
    :change_informasi_gaji, :download, :export, :export_to_xls, :generate_payroll, :print_slip

  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :edit, :destroy, :export, :show, :download, :print, :mine ]
  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('salary_index') ? true : invalid_features
    when "new"
      current_features.include?('salary_new') ? true : invalid_features
    when "edit"
      current_features.include?('salary_edit') ? true : invalid_features
    when "destroy"
      current_features.include?('salary_delete') ? true : invalid_features
    when "export"
      true # current_features.include?('salary_export') ? true : invalid_features
    when "show"
      current_features.include?('salary_detail') ? true : invalid_features
    when "download"
      current_features.include?('salary_download') ? true : invalid_features
    when "print"
      current_features.include?('salary_print') ? true : invalid_features
    when "mine"
      current_features.include?('salary_mine') ? true : invalid_features
    end

    if params[:action] == 'export' && params[:type] == 'bca'
      current_features.include?('salary_click_BCA') ? true : invalid_features
    end
  end

  def index
    add_breadcrumb "Gaji Dan Tunjangan", "#salaries"
    add_breadcrumb "Data Gaji", "#salaries"
    session[:url_act] = "salaries"
    reload_page('honors', 'list_salaries', nil, "stop")
  end

  def reset_list_salaries
    prepare_index
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html 'honors', :partial=> 'list_salaries'
          page << "$('#filter_opt_3').hide()"
          page.replace_html 'filter-period', :partial=> 'periode'
        end
      }
    end
  end

  def mine
    unless current_user.person.blank?
      conditions = "person_id = #{current_user.person.id} AND month(honors.honor_date) >= ? AND year(honors.honor_date) >= ? AND month(honors.honor_date) <= ?  AND year(honors.honor_date) <= ? AND is_thr = false", @month_from, @year_from, @month_to, @year_to
      @honors = Honor.find(:all, :include => :person, :order => 'people.firstname ASC', :conditions => conditions)
    else
      @honors = []
    end

    # ToDo: This will be HR data user
    @person = Person.find_by_user_id(current_user.id) unless current_user.blank?

    @salaries = @honors.paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html {render :layout => false}
      format.js
    end
  end

  def show
    @id = params[:id]
    @salary = Honor.find_and_make_sure_user_has_access(params[:id], current_company_id)
    if @salary
      @honor_month = @salary.honor_month
      render :layout => false
    end
  end

  def destroy
    flash.now[:notice] = "Gaji gaji gagal dihapus"
    unless params[:ids].blank?
      honor= Honor.find(params[:ids])
      honor.each do |p|
        if p.company_id == current_company_id.to_i
          p.destroy
        end
      end
      flash.now[:notice] = "Data gaji berhasil dihapus"
    end
    @is_destroy = true
    
    determine_date
    prepare_index
    reload_page("honors", "list_salaries")
  end

  def get_employee
    company_id = current_company_id
    @people = Person.find(:all, :conditions => "company_id = #{company_id} and latest_employment_id is not null")
    respond_to do |format|
      format.xml
    end
  end

  def new
    add_breadcrumb "Gaji Dan Tunjangan", "#salaries"
    add_breadcrumb "Data Gaji", "#salaries"
    add_breadcrumb "Hitung Gaji", "#new_salary"
    @ps = PayrollSetting.find_by_company_id(current_company_id)
    unless @ps.blank?
      @honor = Honor.new
      prepare_new
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.js
    end
  end

  def informasi_gaji
    @person = Person.find_and_make_sure_user_has_access(params[:person_id], current_company_id)
    add_breadcrumb "Karyawan", "#person_index"
    add_breadcrumb "Daftar karyawan", "#person_index"
    add_breadcrumb "Data Gaji", "#salaries/informasi_gaji?person_id=#{@person.id}"
    render :layout => false
  end

  def edit_informasi_gaji
    @person = Person.find_and_make_sure_user_has_access(params[:person_id], current_company_id)
    add_breadcrumb "Karyawan", "#person_index"
    add_breadcrumb "Daftar karyawan", "#person_index"
    add_breadcrumb "Data Gaji", "#salaries/informasi_gaji?person_id=#{@person.id}"
    add_breadcrumb "Edit data gaji", "#salaries/edit_informasi_gaji?person_id=#{@person.id}"
    render :layout => false
  end

  def change_informasi_gaji
    @person = Person.find_and_make_sure_user_has_access(params[:person]['id'], current_company_id)
    if @person.update_attributes(params[:person])
      reload_page("div_edit_informasi_gaji", "people/informasi_gaji","salaries/informasi_gaji?person_id=#{@person.id}")
    else
      reload_page("div_edit_informasi_gaji", "edit_informasi_gaji")
    end
  end

  def create
    @honor = Honor.new(params[:honor])
    @honor.person_id = params[:honor][:person_id]
    @honor.company_id = current_company_id
    @honor.overtime_compensation = @honor.count_overtimes(@honor.person, params[:honor][:start_period], params[:honor][:end_period])[:total_overtime]
    @person = Person.find(params[:honor][:person_id]) unless params[:honor][:person_id].blank?
    if @honor.save
      @honor.person.salary_master_data.update_attributes(:basic_salary => @honor.salary) unless @honor.person.salary_master_data.blank?
      flash.now[:notice] = "Data gaji berhasil disimpan"
      after_create_data
    else
      flash.now[:notice] = "Data gaji gagal disimpan"
      prepare_new
      reload_page("honor-details", 'honor_details')
    end
  end

  def edit
    @honor = Honor.find_and_make_sure_user_has_access(params[:id], current_company_id)
    @person = @honor.person
    @list_unpaid = []

    @filter_date = Person.format_date_for_ree(@honor.honor_date)

    @start_period = Person.format_date_for_ree(@honor.start_period)
    @end_period = Person.format_date_for_ree(@honor.end_period)

    sequential_salary_cut = @honor.set_salary_with_sequential_salary_cut(@person,@start_period)
    set_another_description(sequential_salary_cut)

    # Get all premiums on his/her company

    #@list_unpaid = @person.absences.list_total_unpaid(@person.company_id, @start_period, @end_period)
    #@list_unpaid = @list_unpaid.collect{ |x| x unless x.is_cut_employee_leave_quota }.compact! unless  @list_unpaid.blank?
    #@honor.salary_cut, @premiums_in_companies = @honor.salary_cut == 0 ? @honor.count_salary_cut(@person, @start_period, @end_period, @list_unpaid) : @honor.salary_cut
   
    @list_unpaid = @person.my_unpaid_absences(@start_period, @end_period)
 
    @honor.salary_cut, @premiums_in_companies = @honor.count_salary_cut(@person, @start_period, @end_period, @list_unpaid)

    unless @honor.blank?
      @salary = @honor.salary
      @current_salary = @person.current_salary.salary unless @person.current_salary.blank?
      @current_salary = @person.current_salary_data_master.basic_salary if !@person.current_salary_data_master.blank? && @current_salary.blank?
    end

    render :layout => false
  end

  def update
    @honor = Honor.find_and_make_sure_user_has_access(params[:id], current_company_id)
    @honor.overtime_compensation = @honor.count_overtimes(@honor.person, @honor.start_period, @honor.end_period)[:total_overtime]
    @person = @honor.person
    if @honor.update_attributes(params['honor'])
      @honor.person.salary_master_data.update_attributes(:basic_salary => @honor.salary) unless @honor.person.salary_master_data.blank?

      unless @honor.file_name.blank?
        last_file = File.exist?("#{RAILS_ROOT}/honors/#{@honor.honor_date.year}/#{@honor.honor_date.month}/#{@honor.file_name}")
      end

      if last_file
        File.delete("#{RAILS_ROOT}/honors/#{@honor.honor_date.year}/#{@honor.honor_date.month}/#{@honor.file_name}")
        generate_salary_receipt
      end

      flash.now[:notice] = "Data gaji berhasil diupdate"
      after_update_data
    else
      flash.now[:notice] = "Data gaji gagal diupdate"
      reload_page("honor-details", 'honor_details')
    end
  end

  def download
    @honor = Honor.find_and_make_sure_user_has_access(params[:id], current_company_id)

    if @honor
      unless @honor.file_name.blank?
        last_file = File.exist?("#{RAILS_ROOT}/honors/#{@honor.honor_date.year}/#{@honor.honor_date.month}/#{@honor.file_name}")
      end

      # Check if pdf file already generated
      # If yes, pdf should not be generated again
      if !last_file
        generate_salary_receipt
        @honor.reload
      end
      send_file "#{RAILS_ROOT}/honors/#{@honor.get_year}/#{@honor.get_month}/#{@honor.file_name}"
    else
      render :nothing => true
    end
  end

  # Export salaries data
  def export
    if params[:type] == 'xls'
      export_to_xls
    elsif params[:type] == 'bca'
      generate_payroll
    elsif params[:type] = 'slip'
      export_to_slip
    else
      redirect_to salaries_path
    end

  end

  require 'rubygems'
  require 'spreadsheet'

  def export_to_xls
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "DaftarGaji" #-#{params[:month_from]}.#{params[:year_from]}-#{params[:month_to]}.#{params[:year_to]}"

    #prepare_export_data_for_title(data_sheet)

    premiums = Premium.all(:conditions => "company_id=#{current_company_id}", :order => "id")
    header = Honor.title_export
    total_header = header.size
    data_sheet.row(5).concat header

    format_row = Spreadsheet::Format.new :size => 10, :border=> 2
    format_border(data_sheet, 0, total_header-1, 5, format_row)

    #last row digunakan untuk mendapatkan row terakhir sehingga bisa diinputkan tanpa department untuk next row
    export_with_department(data_sheet, total_header-1, premiums, format_row)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    file_name = "DaftarGaji.xls" #-#{params[:month_from]}.#{params[:year_from]}-#{params[:month_to]}.#{params[:year_to]}.xls"
    send_data(spreadsheet.string, :type=>"application/excel", :disposition=>'attachment',:filename => file_name)
  end

  require 'fastercsv'
  # Generate payroll for BCA
  def generate_payroll
    unless params[:transfer_date].blank?
      conditions = current_conditions
      conditions << " AND people.bank_name ='bca'"
      @honors = Honor.find(:all, :include => [:person], :conditions => conditions, :order => 'people.firstname ASC')
      total_transfered = Honor.sum(:total_final_take_home_pay, :include => [:person], :conditions => conditions)

      # Get company id
      # TODO: check integration with platform. It should get company_id from platform
      payroll_setting = PayrollSetting.find_by_company_id(current_company_id)

      @transfer_date = Date.strptime(params[:transfer_date], "%d/%m/%Y")
      txt_string = FasterCSV.generate do |txt|
        base_code = "00000000000"                                                     #1-11:tidak digunakan
        bca_brach_code = payroll_setting.bca_branch_code                              #12-15:kode cabang bca
        company_code = payroll_setting.bca_company_code                               #16-20:kode perusahaan (huruf ke-5 = 0)
        company_initial = payroll_setting.bca_company_initial                         #21-24 inisial nama perusahaan
        transfer_date = @transfer_date.strftime('%d')                                 #25-26 tgl transfer
        transfer_code = "01"                                                          #27-28 kode transfer untuk gaji yang selalu 01
        account_number_debited = payroll_setting.bca_company_account_number           #29-38 nomor rekening yg di debet
        account_type = "0"                                                            #39 BCA = '0', Non-bca = '1'
        trsanfer_day_type = "0"                                                       #40 Transfer sebelum hari libur = '0'- Tranfer setelah hari libur = '1'
        transfered_space = "MF"                                                       #41-42 ruang linkup transfer
        total_records_transfered = "%05d" % @honors.count                             #43-47 jumlah total record yg akan ditranfer
        total_salary_transfered = "%017.2f" % total_transfered                        #48-64 jumlah total (gaji + tunjangan) (sudah termasuk 2 angka dibelakang koma)
        month_process = @transfer_date.strftime('%m')                                 #65-66 bulan proses
        year_process = @transfer_date.strftime('%Y')                                  #67-70 tahun proses

        txt << [base_code+bca_brach_code+company_code+company_initial+transfer_date+transfer_code+account_number_debited+account_type+trsanfer_day_type+transfered_space+total_records_transfered+total_salary_transfered+month_process+year_process]
        @honors.each_with_index do |honor, index|
          # if honor.person.bank_name == "bca" || honor.person.bank_name == "BCA"
          base_employee_code = '0'                                                   #1 '0'
          employee_account_number = honor.person.account_number                      #2-11 nomor rekening yang dkredit
          employee_total_salary = ("%016.2f" % honor.total_final_take_home_pay).delete"."  #12-26 jumlah total gaji(sudah termasuk 2 angka dibelakang koma)
          employee_number = "          "                       #27-36 nomor pegawai
          employee_name = "%030s" % honor.person.account_name                        #37-66 nama pegawai
          departement = "    "                                                       #"67-70 dept
          txt << [base_employee_code+employee_account_number+employee_total_salary+employee_number+employee_name+departement]
          # end
        end
      end
      filename = "A-Pay"+@transfer_date.strftime('%Y%m%d')+".txt"
      send_data txt_string,
        :type => 'text; charset=iso8859-1; header=present',
        :disposition => "attachment; filename=#{filename}"
    else
      redirect_to "/a/#{current_permalink}#salaries"
    end
  end

  def print_slip
    @honors = Honor.find(params[:ids].split(','), :limit => 8)
    render :layout => 'honor_slip'
  end

  # Prepare date for filtering honors date
  # def determine_date(month_from = nil, year_from = nil, month_to = nil, year_to = nil)
  def determine_date
    if !params[:date_start].blank? && !params[:date_end].blank?
      @date_start = params[:date_start]
      @date_end = params[:date_end]
    else
      determine_date_now
    end
  end

  def change_divisi_filter
    @divisions = params[:id].blank?? "" :
      Division.by_company(current_company_id).all(:conditions=> "department_id=#{params[:id]}")
    render :update do |page|
      page.replace_html 'filter_opt_3', :partial=> 'salaries/divisi_data', :locals=>{:divisions => @divisions}
    end
  end

  private

  def export_with_department(data_sheet, header, premiums, format_row)
    num_row = 5
    conditions = Honor.get_export_condition_by_department(current_conditions)
    @honors = Honor.find(:all, :include => [:person], :conditions => conditions, :order => 'people.firstname ASC')
    unless @honors.blank?
      num_row = data_export(data_sheet,premiums, header, format_row, num_row)
    end
    return (num_row)
  end

  def export_without_department(data_sheet, header, premiums, format_row, num_row)
    conditions = Honor.get_export_condition_by_department(current_conditions)
    @honors = Honor.find(:all, :include => [:person], :conditions => conditions, :order => 'people.firstname ASC')
    unless @honors.blank?
      num_row = num_row +1
      data_sheet.row(num_row).concat ["","Tanpa Department","","","","","","","",""]
      num_row = data_export(data_sheet,premiums, header, format_row, num_row)
    end
  end

  def data_export(data_sheet,premiums, header, format_row, num_row )
    sum = Honor.variable_sum_export(premiums)
    format_border(data_sheet, 0, header, num_row, format_row )
    @honors.each_with_index do |honor, index|
      unless honor.person.current_status.blank?
        data = Honor.data_export(honor, index, premiums, sum)
        num_row = num_row +1
        data_sheet.row(num_row).concat data[:data]
        sum = data[:sum]
      end
      format_border(data_sheet, 0, header, num_row, format_row )
    end
    if Honor.is_zero(sum)
      num_row = num_row +1
      data_sheet.row(num_row).concat Honor.summary_result_export(sum)
      format_border(data_sheet, 0, header, num_row, format_row )
    end
    return num_row
  end

  def format_border(data_sheet, from, to, value_row, format_row )
    for i in (from..to)
      data_sheet.row(value_row).set_format(i, format_row);
    end
  end

  def prepare_export_data_for_title(data_sheet)
    unless params[:contract_type].blank?
      contract_type = ContractType.find(params[:contract_type],  :select => 'contract_type_name')
      title_01 = ['', "Upah Karyawan Status: #{contract_type.contract_type_name}", ]
    else
      contract_types = ContractType.find(:all, :select => 'contract_type_name', :conditions => "company_id = #{current_company_id}")
      title_01 = ['', "Upah Karyawan Status: #{contract_types.map{ |c| c.contract_type_name}.join(', ')}", ]
    end
    title_02 = ['', "Periode Gaji: #{Date::MONTHNAMES[params[:month_from].to_i]} #{params[:year_from]} - #{Date::MONTHNAMES[params[:month_to].to_i]} #{params[:year_to]}" ]
    # title_03 = ['', 'Periode cut-off gaji:' ]
    title_03 = ['', "Tgl Bayar: #{Time.now.strftime('%e %B %Y')}"]

    data_sheet.row(1).replace title_01
    data_sheet.row(2).replace title_02
    data_sheet.row(3).replace title_03
    # data_sheet.row(3).replace title_04

    format_title = Spreadsheet::Format.new :weight => :bold, :size => 10
    data_sheet.row(1).default_format = format_title
    data_sheet.row(2).default_format = format_title
    data_sheet.row(3).default_format = format_title
    # data_sheet.row(3).default_format = format_title

    data_sheet.row(4).replace [" "]

  end

  def determine_date_now
    @date_start = Time.now.strftime("%Y-%m-01")
    @date_end = Date.parse(Time.now.strftime("%Y-%m-%d")).end_of_month.strftime("%Y-%m-%d")
  end

  def prepare_new
    time_now = Time.now
    @list_unpaid = []
    # @start_period = params[:start_date]
    # @end_period = params[:end_date]

    unless params[:start_date].blank? && params[:end_date].blank?
      @start_period = Person.format_date(params[:start_date])
      @end_period = Person.format_date(params[:end_date])
     
      unless params[:date].blank?
        @honor_month = params[:date][:month].to_i
        @honor_year = params[:date][:year].to_i
      else
        @honor_month = time_now.month
        @honor_year = time_now.year
      end

      @filter_date = time_now.to_date
      last_month = time_now.month - 1
      unless params[:person_id].blank?
        @person = Person.get_person_name_by_department_and_division(params[:person], current_company_id)
        unless @person.blank?
          @current_salary = @person.current_salary.salary unless @person.current_salary.blank?
          @current_salary = @person.current_salary_data_master.basic_salary if !@person.current_salary_data_master.blank? && @current_salary.blank?
        end
      end
      # Prepopulate data
      if params[:action] != 'create' && !@person.blank?
        sequential_salary_cut = @honor.set_salary_with_sequential_salary_cut(@person,@start_period)
        set_another_description(sequential_salary_cut)

        @list_unpaid = @person.my_unpaid_absences(@start_period, @end_period)
        @honor.salary_cut, @premiums_in_companies = @honor.count_salary_cut(@person, @start_period, @end_period, @list_unpaid)
      end

      unless @person.blank?
        @salary = @honor.count_salary(@person,@start_period, @end_period)
        total_overtimes = @honor.count_overtimes(@person, @start_period, @end_period)

        # Jumlah jam lembur
        @total_overtime_hours = total_overtimes[:total_overtime_hours]

        # Tarif lembur
        @overtime_hourly_rate = @honor.overtime_hourly_rate(@person, @start_period, @end_period, @total_overtime_hours) unless @person.company_hr_setting.is_company_overtime

        # Jumlah jam lembur yang sudak dikalikan dengan pengali
        @total_overtime_modifiers = total_overtimes[:total_overtime_modifiers]

        # Jumlah jam lembur yang sudah dikalikan dengan pengali dan rate nya
        @total_overtime_values = total_overtimes[:total_overtime]

        # Get person overtime list
        @overtimes = total_overtimes[:overtimes]

        # @total_work_days = @person.presences.total_work_days(@honor_month, @honor_year)
        @total_work_days = @person.presences.cut_off_total_work_days(@start_period, @end_period)[:days] unless @person.presences.blank?

        # Cuti diuangkan
        # Note by Feby: Emang ini dipake gitu ?
        #@this_year_quota = @person.leave_quota
        @last_year_quota = @person.leaves_quotas.my_quota(@this_year_quota.blank? ? Date.today - 1.year : @this_year_quota.start_date.to_date - 1.day)
        
        # is_redeem_to_money
        if @last_year_quota && @last_year_quota.is_redeem_to_money && @last_year_quota.paid_redeem_date.blank?
          if !@honor.salary_cut.blank? && !@list_unpaid.blank?
            premium_leaave, premiums = @honor.count_total_premium_cut(@person, 1)
            @salary_in_a_day = (@honor.salary/@honor.assumed_working_days(@person))+premium_leaave
            @honor.leaves_redemption = (@last_year_quota.redeemed_days*@salary_in_a_day).to_i
          else
            @honor.leaves_redemption = 0
          end        
        end
        # Cek apakah karyawan tersebut masih memiliki absen tidak masuk kerja yang belum di tindak lanjuti
        # Notifikasi user jika masih ada
        # conditions = []
        conditions = ['person_id = ? AND date BETWEEN ? AND ? AND absence_id IS NULL AND presence_id IS NULL AND (work_duration IS NOT NULL OR overtime_duration IS NOT NULL)', @person, @start_period, @end_period]
        # conditions << "AND work_duration IS NOT NULL OR overtime_duration IS NOT NULL"
        @has_not_followed_up = PresenceReport.find(:all, :select => 'person_id, date', :conditions => conditions, :order => :date)
        @total_excuse = @person.absences.total_by_type(1, @start_period, @end_period, current_company_id)
        @total_sick_leave = @person.absences.total_by_type(3, @start_period, @end_period, current_company_id)
      end
    end

  end

  def set_another_description(sequential_salary_cut)
    @desc = sequential_salary_cut[:desc]
    @tot_sakit = sequential_salary_cut[:tot_sakit]
  end

  def prepare_index    
    @payroll_setting = PayrollSetting.find_by_company_id(current_company_id)
    @contract_type_id = params[:filter][:contract_type_id] unless params[:filter].blank?
    @per_page = 10
    company_id = current_company_id
    #conditions = "((honors.start_period >= '#{@date_start}' AND honors.start_period <= '#{@date_end}') OR (honors.end_period >= '#{@date_start}' AND honors.end_period <= '#{@date_start}') OR (honors.start_period >= '#{@date_start}' AND honors.end_period <= '#{@date_end}')) AND is_thr = false AND honors.company_id = #{company_id}"
    #conditions = "honors.start_period >= '#{@date_start}' AND honors.end_period <= '#{@date_end}' AND is_thr = false AND honors.company_id = #{company_id}"
    conditions = "honors.end_period >= '#{@date_start}' AND honors.end_period <= '#{@date_end}' AND is_thr = false AND honors.company_id = #{company_id}"
    unless params[:filter].blank?
      filter_cond = Honor.find_by_filter(params[:filter])
      conditions << " AND " unless filter_cond.blank?
      conditions << filter_cond
    end

    session[:conditions] = conditions    
    @honors = Honor.find(:all, :include => :person, :order => 'people.firstname ASC, honor_date DESC', :conditions => conditions)
    if @is_destroy == true
      params[:page] = params[:current_page] 
      @salaries = @honors.paginate(:page => params[:page], :per_page => @per_page)   
      if @salaries.count == 0
        curr_page = params[:page].to_i - 1        
        params[:page] = curr_page.to_s if curr_page > 0      
      end 
    end
    @salaries = @honors.paginate(:page => params[:page], :per_page => @per_page)   
    @salaries_all = Honor.count(:conditions => "company_id =#{current_company_id}")
  end

  def after_create_data
    if params[:honor][:item_kembali] == "lanjut"
      render :update do |page|
        page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
        page << "$('#person-details').hide();"
        page << "$('#honor-details').hide();"
        page << "$('#person-name').val('');"
        page << "$('#honor_salary').val('');"
      end
    else
      determine_date
      prepare_index
      reload_page("div_new", "list_index","salaries")
    end
  end

  def after_update_data
    if params[:honor][:item_kembali] == "lanjut"
      render :update do |page|
        page << "$('#honor_salary').val('');"
      end
    else
      determine_date
      prepare_index
      reload_page("div_edit", "list_index","salaries")
    end
  end

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name
          page << "stop_filter2()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def generate_salary_receipt
    total_salary = "Total dibayarkan bulan ini: #{@template.format_currency(@honor.gross_income)} - #{@template.format_currency(@honor.pph_indebted_per_month)}"
    result_salary = " = #{@template.format_currency(total_salary)}"

    FileUtils.mkdir_p "honors/#{@honor.get_year}/#{@honor.get_month}"
    file_name = @honor.person.firstname + '_' + @honor.person.lastname + '_'+@honor.honor_date.strftime('%d_%m_%Y')
    Prawn::Document.generate "#{RAILS_ROOT}/honors/#{@honor.get_year}/#{@honor.get_month}/honor_#{file_name}.pdf" do |pdf|;
      pdf.font_size 9
      pdf.move_down 50
      pdf.text "SLIP GAJI", :align => :center, :size => 10, :style => :bold
      pdf.move_down 10
      periode = "#{@honor.start_period.strftime('%e %b %Y')} - #{@honor.end_period.strftime('%e %b %Y')}" unless @honor.start_period.blank? && @honor.end_period.blank?
      honor_date = @honor.honor_date.strftime('%e %b %Y') unless @honor.honor_date.blank?
      position_expenses = "5% x #{@template.format_currency(@honor.gross_income)}" if !@honor.person.current_work_contract.blank? && !@honor.person.current_work_contract.is_daily_employee
      pdf.table [
        ["Periode", ":", "#{periode}"],
        ["Nama", ":", "#{@honor.person.full_name}"],
        ["KTP", ":", "#{@honor.person.no_ktp}"],
        ["NPWP", ":", "#{@honor.person.no_npwp}"]
      ], :cell_style => { :borders => [] }
      pdf.move_down 20
      salary = []
      salary << ["Gaji", "", "#{@template.format_currency(@honor.salary)}"]
      unless @honor.salary_cut.blank? || @honor.salary_cut == 0
        salary << ["Potongan Absensi", "", "- #{@template.format_currency(@honor.salary_cut)}"]
      end
      salary << ["Bonus", "", "#{@template.format_currency(@honor.bonus)}"] unless @honor.bonus.blank?
      if @honor.overtime_compensation.to_f > 0
        salary << ["Lembur", "", "#{@template.format_currency(@honor.overtime_compensation)}"] unless @honor.overtime_compensation.blank?
      end
      @honor.premium_in_honors.each do |pic|
        unless pic.premium.blank? || pic.premium_value == 0
          salary << ["#{pic.premium.premium_name}", "", "#{@template.format_currency(pic.premium_value)}"]
        end
      end
      salary << ["Penghasilan Bruto", "", "#{@template.format_currency(@honor.gross_income)}"]
      salary << ["Biaya Jabatan", "#{position_expenses}", "#{@template.format_currency(@honor.position_expenses)}"]
      salary << ["Penghasilan Netto/bulan", "", "#{@template.format_currency(@honor.month_net_income)}"]

      salary_2 = []
      salary_3 = []
      salary_4 = []

      if @honor.count_for_december?
        salary_2 << ["Penghasilan Tahun #{@honor.end_period.year}", "(Total Gaji, THR dll )", "#{@template.format_currency(@honor.year_net_income)}"]
        salary_2 << ["PTKP", "", "#{@template.format_currency(@honor.ptkp)}"]
        salary_2 << ["PKP", "", "#{@template.format_currency(@honor.pkp)}"]

        total_net_income, paid_tax = @honor.count_paid_tax
        salary_2 << ["PPH 21 Yang Harus dibayar di #{@honor.end_period.year} ", "", "#{@template.format_currency(@honor.pph_indebted_per_year)}"]
        salary_3 << ["PPH 21 Yang Sudah dibayar di #{@honor.end_period.year} ", "", "#{@template.format_currency(paid_tax)}"]
        salary_3 <<  ["PPH 21 bulan ini", "(#{@template.format_currency(@honor.pph_indebted_per_year)}) - (#{@template.format_currency(paid_tax)})", "#{@template.format_currency(@honor.pph_indebted_per_month)}"]

      else
        salary_2 << ["Penghasilan Netto/tahun", "#{@honor.count_month} x #{@template.format_currency(@honor.month_net_income)}", "#{@template.format_currency(@honor.year_net_income)}"]
        salary_2 << ["PTKP", "", "#{@template.format_currency(@honor.ptkp)}"]
        salary_2 << ["Pendapatan Kena Pajak", "", "#{@template.format_currency(@honor.pkp)}"]
        salary_2 << ["PPH 21", "#{('120% x'if @honor.person.no_npwp.blank?)} 5% x #{@template.format_currency(@honor.pkp)}", "#{@template.format_currency(@honor.pph_indebted_per_year)}"]

        salary_3 <<  ["PPH 21 bulan ini", "#{@template.format_currency(@honor.pph_indebted_per_year)}/12", "#{@template.format_currency(@honor.pph_indebted_per_month)}"]
      end
      salary_4 << ["Total dibayarkan bulan ini:", "", "#{@template.format_currency(@honor.gross_income)}"]
      salary_4 <<  ["", "", "- #{@template.format_currency(@honor.pph_indebted_per_month)} (PPh 21)"]

      salary_4 <<  ["", "Potongan Jamsostek","- #{@template.format_currency(@honor.jamsostek_cut)}"] unless @honor.jamsostek_cut.blank? || @honor.jamsostek_cut == 0
      salary_4 <<  ["", "Potongan Pinjaman","- #{@template.format_currency(@honor.debt)}"] unless @honor.debt.blank? || @honor.debt == 0
      salary_4 <<  ["", "Potongan PUMP Jamsostek","- #{@template.format_currency(@honor.jamsostek_house_cut)}"] unless @honor.jamsostek_house_cut.blank? || @honor.jamsostek_house_cut == 0
      salary_4 <<  ["", "Potongan Koperasi","- #{@template.format_currency(@honor.cooperation_cut)}"] unless @honor.cooperation_cut.blank? || @honor.cooperation_cut == 0
      salary_4 <<  ["", "Kelebihan bayar kepada #{current_company} bulan lalu","#{@template.format_currency(@honor.more_adjustment)}"] unless @honor.more_adjustment.blank? || @honor.more_adjustment == 0
      salary_4 <<  ["", "Pembulatan","#{@template.format_no_currency(@honor.rounding_off)}"] unless @honor.rounding_off.blank? || @honor.rounding_off == 0

      salary_4 << ["", "", "#{@template.format_currency(@honor.total_final_take_home_pay)}"]

      pdf.table salary, :column_widths => { 0 => 210, 1 => 150, 2 => 180}  do
        style(row(0),  :borders => [:top, :left, :right])
        style(row(1),  :borders => [:left, :right] )
        style(row(2),  :borders => [:left, :right] )
        style(row(3),  :borders => [:left, :right] )
        style(row(4),  :borders => [:left, :right, :bottom] )
      end

      pdf.move_down 10
      pdf.table salary_2, :column_widths => { 0 => 210, 1 => 150, 2 => 180} do
        style(row(0),  :borders => [:top, :left, :right] )
        style(row(1),  :borders => [:left, :right] )
        style(row(2),  :borders => [:left, :right])
        style(row(3),  :borders => [:left, :right, :bottom])
      end

      pdf.move_down 10
      pdf.table salary_3, :column_widths => { 0 => 210, 1 => 150, 2 => 180} do
        style(row(0),  :borders => [:top, :left, :right, :bottom] )
      end

      # pdf.move_down 20
      pdf.table salary_4,  :column_widths => { 0 => 210, 1 => 150, 2 => 180},
        :cell_style => { :borders => [] }

      pdf.move_down 10
      pdf.text session[:platform_user]['user']['user_company']['name']
      pdf.move_down 50
      pdf.table [[""]], :column_widths => { 0 => 100}, :cell_style => { :borders => [:bottom] }

    end
    @page = params[:page_from]
    @index = params[:cid]

    @honor.update_attributes(:file_name => "honor_#{file_name}.pdf", :skip_before_save => true)
  end
  
end

