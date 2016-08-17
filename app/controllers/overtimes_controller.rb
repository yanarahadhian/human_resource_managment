class OvertimesController < ApplicationController
  before_filter :login_required
  before_filter :current_company
  before_filter :filter_options, :only => [:index_done, :overtime_table, :overtime_data_table, :overtime_report_table, :overtime_report_export]

  ssl_required :check_features, :index_done, :overtime_table, :overtime_data_create, :add_group
  before_filter :current_features
  before_filter :check_features, :only => [:index, :index_done, :update_status]#, :overtime_report_table]
  before_filter :prepare_index, :only =>  [:index]
  #  Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('overtime_plan_list') ? true : invalid_features
    when "update_status"
      current_features.include?('overtime_status_update') ? true : invalid_features
    when "overtime_report_table"
      current_features.include?('overtime_recap') ? true : invalid_features
    when "index_done"
      current_features.include?('overtime_index') ? true : invalid_features
      #     when "show"
      #       current_features.include?('overtime_detail') ? true : invalid_features
      #     when "new"
      #       current_features.include?('overtime_new') ? true : invalid_features
      #     when "edit"
      #       current_features.include?('overtime_edit') ? true : invalid_features
      #     when "destroy"
      #       current_features.include?('overtime_delete') ? true : invalid_features
    end
    # return true
  end

  def index
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Rencana lembur", "#overtimes"
    reload_page('div_list_overtimes','list_overtimes','overtimes','ada')
  end

  def index_done
    session[:url_act] = "overtimes/index_done"
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Daftar lembur", "#overtimes/index_done"
    @overtime_exist = Overtime.all(:conditions => {:company_id => current_company_id}, :limit => 1).count
    @overtimes = Overtime.who_take_overtime(current_company_id, @date_start, @date_end)
    render :layout => false
  end

  def overtime_table
    @total_overtimes = Overtime.who_take_overtime(current_company_id, @date_start, @date_end, @options)
    set_data_to_session("overtimes/index_done")
    @overtimes = @total_overtimes[ (@start_index) .. (@start_index + @display_length - 1) ]
    @iTotalRecords = @total_overtimes.count
    @iTotalDisplayRecords = @overtimes.count
    @sEcho = params[:sEcho].to_i
    render :partial => 'overtimes/overtime_table'
  end

  def overtime_data_table
    if current_features.include?('overtime_status_update')
      @total_overtimes = OvertimeData.overtime_plan(current_company_id, @date_start, @date_end)
    else
      @person = Person.find_by_user_id(current_user.id)
      if @person
        @total_overtimes = @person.overtimedatas.find(:all, :conditions => ['(? BETWEEN start_periode AND end_periode) OR (? BETWEEN start_periode AND end_periode)', @date_start, @date_end])
      end
    end
    @overtimes = @total_overtimes[ (@start_index) .. (@start_index + @display_length - 1) ] if @total_overtimes
    @iTotalRecords = @total_overtimes.count rescue 0
    @iTotalDisplayRecords = @overtimes.count rescue 0
    @sEcho = params[:sEcho].to_i
    render :partial => 'overtimes/overtime_data_table'
  end

  def update_status
    flash.now[:notice] = "Rencana lembur gagal diapprove!" if params[:act_name] == "approved"
    flash.now[:notice] = "Rencana lembur gagal direject!" if params[:act_name] == "rejected"
    unless params[:ids].blank?
      data = OvertimeData.find(params[:ids])
      data.each do |d|
        d.update_attribute(:status, params[:act_name])
        flash.now[:notice] = "Rencana lembur berhasil diapprove!" if params[:act_name] == "approved"
        flash.now[:notice] = "Rencana lembur berhasil direject!" if params[:act_name] == "rejected"
      end
    end
    render :nothing => true, :status => 201
  end

  def delete_multiple
    flash.now[:notice] = "Rencana lembur gagal dihapus!"
    unless params[:ids].blank?
      data = OvertimeData.find(params[:ids])
      data.each do |p|
        p.delete
        flash.now[:notice] = "Rencana lembur berhasil dihapus!"
      end
    end
    render :nothing => true, :status => 201
  end

  def edit
    @divisions = Division.find(:all, :conditions =>['company_id = ?', current_company_id])
    @overtime = OvertimeData.find(params[:id])
    render :layout => false
  end

  def new
    #the_people = Person.find(:all, :conditions => ['company_id = ? and latest_employment_id is not null', current_company_id])
    @divisions = Division.find(:all, :conditions =>['company_id = ?', current_company_id])
    @overtimedata = OvertimeData.new
    render :layout => false
  end

  def overtime_data_create
    option_err = Overtime.get_option_err(params)
    unless option_err.blank?
      flash.now[:notice]="Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!"
      get_error_create_overtime(option_err)
    else
      people = Overtime.get_person(params, current_company_id)
      flash.now[:notice] = "Rencana lembur gagal disimpan!"
      unless people.blank?
        people.each do |person|
          overtimedata = get_overtimedata(person.id)
          overtimedata.save
          flash.now[:notice] = "Rencana lembur berhasil disimpan!"
        end
        prepare_index
        reload_page("div_new_sp","index","overtimes")
      else
        flash.now[:notice] = "Rencana lembur gagal disimpan. karena data karyawan tidak tersedia!"
        get_error_create_overtime
      end
    end
  end

  def update
    @overtime = OvertimeData.find_by_id_and_company_id(params[:id], current_company_id)
    person = Person.get_person_name_by_department_and_division(params[:employees], current_company_id)
    overtimedata = get_overtimedata(person.id)
    if @overtime && @overtime.update_attributes(overtimedata)
      prepare_index(@overtime.start_periode, @overtime.end_periode)
      flash.now[:notice] = "Rencana lembur berhasil diupdate"
      reload_page("div_edit","index","overtimes","ada")
    else
      flash.now[:notice] = "Rencana lembur gagal diupdate"
      reload_page("div_edit","edit")
    end
    #    @period_in_minutes = @overtime.company.hr_setting.period_in_minutes ||= 1
    #    if @overtime.end_overtime
    #      @overtime.length_in_minutes = (@overtime.end_overtime - @overtime.start_overtime) / 60
    #      @overtime.length_in_minutes = (@overtime.length_in_minutes / @period_in_minutes).floor * @period_in_minutes
    #    end

  end

  def show
  end

  def overtime_report
    render :layout => false
  end

  def overtime_report_table
    session[:conditions] = @options
    @total_overtime_reports = Overtime.summary_recap(current_company_id, @date_start, @date_end, @options)
    @overtime_reports = @total_overtime_reports
    @overtime_reports = @overtime_reports[ (@start_index) .. (@start_index + @display_length - 1) ]

    @iTotalRecords = @total_overtime_reports.count
    @iTotalDisplayRecords = @overtime_reports.count
    @sEcho = params[:sEcho].to_i
    render :partial => '/overtimes/overtime_report_table'
  end

  def overtime_report_export
    @total_overtime_reports = Overtime.summary_recap(current_company_id, @date_start, @date_end, current_conditions)
    @overtime_reports = @total_overtime_reports
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Lembur"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['No','Department','Nik','Nama karyawan','Total Lembur Wajib','Total Lembut Tidak Wajib']
    data_sheet = set_data_export_rekap_lembur(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "lembur.xls", :type =>  "application/vnd.ms-excel"
  end

  def add_group
    unless params['value'].blank?
      @groups = WorkGroup.find(:all, :conditions => ['division_id = ?', params['value']])
      @index = params[:index]
    end
    render :layout => false
  end

  def export_overtime
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Lembur"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Nama Karyawan','Department','Bagian','Tanggal','Lama Lembur','Status','Alasan']
    data_sheet = set_data_export_lembur_table(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "lembur.xls", :type =>  "application/vnd.ms-excel"
  end

  private

  def set_data_export_rekap_lembur(data_sheet)
    @overtime_reports.each_with_index do |overtime, index|
      data_sheet.row(index+1).replace [ index+1 ,
        overtime[:department].blank? ? "":overtime[:department].department_name ,
        overtime[:person].employee_identification_number,
        overtime[:person].full_name,
        Presence.minutes_to_hour_text(overtime[:compulsory_overtime]),
        Presence.minutes_to_hour_text(overtime[:nc_overtime]) ]
    end
  end

  def set_data_export_lembur_table(data_sheet)
    get_data_from_session
    @total_overtimes = Overtime.who_take_overtime(current_company_id, @date_start, @date_end, @options)
    @total_overtimes.each_with_index do |overtime, index|
      data_sheet.row(index+1).replace [overtime.person.full_name.titleize,
        overtime.person.department(overtime.overtime_date).blank? ? "" : overtime.person.department(overtime.overtime_date).department_name.just_display,
        overtime.person.division(overtime.overtime_date).blank? ? "" : overtime.person.division(overtime.overtime_date).name.just_display,
        overtime.overtime_date,
        Presence.minutes_to_hour_text(overtime.overtime_length_in_minutes),
        overtime.overtime_status,
        overtime.overtime_description
      ]
    end unless @total_overtimes.blank?
  end

  def get_error_create_overtime(option_err="")
    @divisions = Division.find(:all, :conditions =>['company_id = ?', current_company_id])
    @overtimedata = get_overtimedata(nil)
    @overtimedata.save
    @overtimedata.errors.add_to_base(option_err)
    reload_page("div_new_sp","new")
  end

  def get_overtimedata(person_id)
    if params[:action] == "update"
      start_overtime = "#{params[:overtime_data]["start_overtime(4i)"]} #{params[:overtime_data]["start_overtime(5i)"]}"
      data ={:person_id => person_id,
        :start_periode => params[:overtime_data]['start_date'],
        :end_periode => params[:overtime_data]['end_date'],
        :reason => params[:overtime_data]['reason'],
        :company_id => current_company_id,
        :start_overtime => start_overtime,
        :status => params[:overtime_status]}
      return data
    else
      start_overtime = "#{params['start_working'][:hour]} #{params['start_working'][:minute]}"
      data ={:person_id => person_id,
        :start_periode => params['start_date'],
        :end_periode => params['end_date'],
        :reason => params['reason'],
        :company_id => current_company_id,
        :start_overtime => start_overtime,
        :status => params[:overtime_status]}
      return OvertimeData.new(data)
    end
  end

  def prepare_index(start_periode = nil, end_periode = nil)
    #if current_features.include?('overtime_status_update')
    @per_page = 10
    params[:filter]={} if start_periode || end_periode
    params[:filter][:start_periode] = start_periode.strftime("%d/%m/%Y") unless start_periode.blank?
    params[:filter][:end_periode] = end_periode.strftime("%d/%m/%Y") unless end_periode.blank?
    kond = "overtime_datas.start_periode <= '#{Time.now.strftime("%F")}' AND overtime_datas.end_periode >= '#{Time.now.strftime("%F")}'"
    kond = OvertimeData.search(params[:filter])  unless params[:filter].blank?
    @overtimes = OvertimeData.by_company(current_company_id).paginate(:conditions =>  kond, :page => params[:page], :per_page => @per_page)
    #    else
    #      @person = Person.find_by_user_id(current_user.id)
    #      if @person
    #        @overtimes = @person.overtime_datas
    #      end
    #end
    @overtimes_all = OvertimeData.count(:conditions => "company_id=#{current_company_id}")
  end

  def filter_options
    @date_start = params[:date_start].blank? || params[:date_start] == "undefined" ? Date.today : Date.parse(params[:date_start])
    @date_end = params[:date_end].blank? || params[:date_end] == "undefined" ? @date_start : Date.parse(params[:date_end])
    @options = {}
    name = params[:name] if params[:name] != "undefined"
    nik = params[:nik] if params[:nik] != "undefined"
    department = params[:department].to_i
    division = params[:division].to_i
    contract = params[:contract].to_i
    unless name.blank?
      @options[:condition] = "(firstname LIKE '%#{name}%' OR lastname LIKE '%#{name}%' OR CONCAT(TRIM(firstname),' ',TRIM(lastname)) LIKE '%#{name}%')"
    end
    unless nik.blank?
      if @options[:condition]
        @options[:condition] = [@options[:condition], "employee_identification_number LIKE '%#{nik}%'"].join(" AND ")
      else
        @options[:condition] = "employee_identification_number LIKE '%#{nik}%'"
      end
    end
    if department != 0
      @options[:department_id] = department
    end
    if division != 0
      @options[:division_id] = division
    end
    if contract != 0
      @options[:contract_type] = contract
    end
    @display_length = params[:iDisplayLength].to_i
    @start_index = params[:iDisplayStart].to_i
  end

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')"  unless flash.now[:notice].blank?
          page << "parent.$.fn.colorbox.close();"
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def set_data_to_session(str_action_name)
    session[:url_act] = str_action_name
    session[:start_date] = @date_start
    session[:end_date] = @date_end
    session[:option] = @options
  end

  def get_data_from_session
    @date_start = session[:start_date]
    @date_end = session[:end_date]
    @options = session[:option]
    #delete_data_session
  end

  def delete_data_session
    session.delete(:url_act)
    session.delete(:start_date)
    session.delete(:end_date)
    session.delete(:option)
  end

end

