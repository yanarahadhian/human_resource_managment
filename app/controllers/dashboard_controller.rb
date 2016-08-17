class DashboardController < ApplicationController

  add_breadcrumb "Laporan lainnya", "#view_absensi"
  before_filter :get_person_by_company, :only => [:page_chart, :get_status_table]
  before_filter :login_required
  before_filter :get_people_ids, :only => [:get_status_table, :get_accident_table, :get_sp_table, :get_mutasi_table, :get_formasi_table, :get_absensi_table]

  ssl_required :check_features, :show_statistik_page,  :find_statistik_get, :get_person_by_company, :get_howto

  before_filter :current_features
  before_filter :check_features, :only => [:get_absensi_table, :page_chart]
  before_filter :prepare_all, :only =>[:index, :view_rekap_absensi, :view_laporan_ketidakhadiran, :view_rekap_overtime]
  # Check features accessability by user roles
  def check_features
#    case params[:filter]
#    when "absensi"
#      current_features.include?('absent_report') ? true : invalid_features
#    when "formasi"
#      current_features.include?('formation_gender_report') ? true : invalid_features
#    when "formasi_jabatan"
#      current_features.include?('formation_position_report') ? true : invalid_features
#    when "formasi_departemen"
#      current_features.include?('formation_report') ? true : invalid_features
#    when "formasi_bagian"
#      current_features.include?('formation_division_report') ? true : invalid_features
#    when "accident"
#      current_features.include?('accident_report') ? true : invalid_features
#    when "mutasi"
#      current_features.include?('in_out_employee_report') ? true : invalid_features
#    when "sp"
#      current_features.include?('sp_report') ? true : invalid_features
#    when "status"
#      current_features.include?('employee_status_report') ? true : invalid_features
#    when "rekap_absensi"
#      current_features.include?('present_report') ? true : invalid_features
#    when "rekap_lembur"
#      current_features.include?('overtime_recap') ? true : invalid_features
#    end
    return true
  end

  def index
    @minta_cuti = 0
    @minta_cuti_diuangkan = 0
    render :layout => false
  end

  def view_absensi
    add_breadcrumb "Absensi", "#view_absensi"
    render :layout => false
  end

  def view_laporan_ketidakhadiran
    add_breadcrumb "Laporan Ketidakhadiran", "#view_laporan_ketidakhadiran"
    render :layout => false
  end

  def view_rekap_absensi
    add_breadcrumb "Rekap Absensi", "#view_rekap_absensi"
    render :layout => false
  end

  def view_rekap_overtime
    add_breadcrumb "Rekap Lembur", "#view_rekap_overtime"
    render :layout => false
  end

  def view_formasi
    add_breadcrumb "Formasi Jenis Kelamin", "#view_formasi"
    render :layout => false
  end

  def view_formasi_jabatan
    add_breadcrumb "Formasi Jabatan", "#view_formasi_jabatan"
    render :layout => false
  end

  def view_formasi_departemen
    add_breadcrumb "Formasi Departemen", "#view_formasi_departemen"
    render :layout => false
  end

  def view_formasi_bagian
    add_breadcrumb "Formasi Bagian", "#view_formasi_bagian"
    render :layout => false
  end

  def view_mutasi
    render :layout => false
  end

  def view_status
    add_breadcrumb "Status Kontrak", "#view_status"
    render :layout => false
  end

  def view_sp
    add_breadcrumb "SP", "#view_sp"
    render :layout => false
  end

  def view_accident
    add_breadcrumb "Kecelakaan kerja", "#view_accident"
    render :layout => false
  end

  #rekap lembur ditampilkan dengan ajax
  def view_rekap_lembur
    @departments = Department.all(:conditions => {:company_id => current_company_id}, :order => "department_name")
    @divisions = Division.all(:conditions => {:company_id => current_company_id}, :order => "name")
    @contract_types = ContractType.all(:conditions => {:company_id => current_company_id}, :order => "contract_type_name")
    render :update do |page|
      page.replace_html "div_rekap_lembur", :partial => "/dashboard/view_rekap_lembur",
                                     :locals => { :departments => @departments,
                                                  :divisions => @divisions }
    end
  end

  # menampilkan isi dari content "Lainnya"
  def content_others
    @mangkir = Absence.sequential_absences(current_company_id, 4)
    @late = Presence.sequential_late(current_company_id)
    render :update do |page|
      page.replace_html "div_view_lainnya", :partial => "/dashboard/content_others",
                                     :locals => { :mangkir => @mangkir,
                                                  :late => @late }
    end
  end

  def page_chart
    if ["formasi","formasi_jabatan","formasi_departemen","formasi_bagian"].include?(params[:filter])
      get_formasi_chart
    elsif params[:filter]=="mutasi"
      get_mutasi_chart
    elsif params[:filter] == "accident"
      get_accident_chart
    elsif params[:filter]=="status"
      get_status_chart
    elsif params[:filter]=="sp"
      get_sp_chart
    elsif params[:filter] == "absensi"
      get_absensi_chart
    end
    render :layout => false
  end

  def show_statistik_page
    if params[:txt_page] == "statistik"
      find_statistik_get
    else
      @mangkir = Absence.sequential_absences(@current_company_id, 4)
      @late = Presence.sequential_late(@current_company_id)
      @minta_cuti = 0
      @minta_cuti_diuangkan = 0
      render :update do |page|
        page.replace_html "div_view_absensi", :partial => "dashboard/view_absensi"
        page << "stop_load_filter()"
      end
    end
  end

  def find_statistik_get
    param = get_url_param_for_statistik(params)
    render :update do |page|
      if params[:txt_action] == "absensi" && params[:filter_absensi].blank?
        page.replace_html "div_view_absensi", :partial => "dashboard/view_absensi"
      end
      page << "$('#div_content_#{params[:txt_action]}').html('<iframe src=\"#{ApplicationController::BASE_URL}/dashboard/page_chart?#{param}\" frameborder=\"0\" width=\"100%\" height=\"500px\" scrolling=\"no\")></iframe>')"
      page << "$('#table-fix_#{params[:txt_action]}').show()" if ["status","accident","sp","mutasi","formasi","formasi_jabatan","formasi_departemen","formasi_bagian","absensi"].include?(params[:txt_action])
      page << "$('#div_#{params[:txt_action]}').show()"
      page << "$('#button_#{params[:txt_action]}_submit').show();$('#load_#{params[:txt_action]}').hide();" if params[:txt_action] != "absensi"
      page << "stop_load_filter()"
    end
  end

  def edit
    render :layout => "application2"
  end

  def get_person_by_company
    condition = Person.without_keluar_masuk + " AND people.company_id=#{current_company_id}"
    if params[:txt_action] == "mutasi"
      @person = Person.search_by_gender_status(params[:filter_mutasi], "people.company_id=#{current_company_id}")
    else
      @person = Person.all(:include=>[:employments], :conditions => condition )
    end
  end

  def get_people_ids
    get_person_by_company
    @ids_person = @person.collect{|x| x.id}
  end

=begin
  def get_howto
    # require "net/http"
    # require "uri"
    # uri = URI.parse("#{ApplicationController::APPSCHEF_URL}/api/users/already_logged_out/#{session[:user_log_id]}")
    # data = Net::HTTP.get(uri)
    # a = ActiveSupport::JSON.decode(data)
    # render :text => a['already_logged_out']
    # /api/users/:user_log_id/update_active_time
    # .'api/'.API_KEY.'/how_to?page_url='.$_REQUEST['page_url'].$hash;

    require 'net/http'
    url = URI.parse("#{ApplicationController::APPSCHEF_URL}/api/#{APPSCHEF_API_KEY}/how_to?page_url=#{params[:page_url]}")
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
    render :json => a
  end
=end

  def get_absensi_table
    prepare_absensi
    action_for_render("absensi",@absences,@page_num,@sortby,@direction)
  end

  def get_status_table
    prepare_status
    action_for_render("status",@contracts,@page_num,@sortby,@direction)
  end

  def get_accident_table
    prepare_accident
    action_for_render("accident",@accidents,@page_num,@sortby,@direction)
  end

  def get_sp_table
    prepare_sp
    action_for_render("sp",@violations,@page_num,@sortby,@direction)
  end

  def get_mutasi_table
    prepare_mutasi
    action_for_render("mutasi",@employments,@page_num,@sortby,@direction)
  end

  def get_formasi_table
    prepare_formasi
    action_for_render(params[:filter],@formasi,@page_num,@sortby,@direction)
  end

  private

  def prepare_all
    @date_start = Date.today
    @date_end = @date_start
    @departments = Department.all(:conditions => {:company_id => current_company_id}, :order => "department_name")
    @divisions = Division.all(:conditions => {:company_id => current_company_id}, :order => "name")
    @contract_types = ContractType.all(:conditions => {:company_id => current_company_id}, :order => "contract_type_name")
  end

  def prepare_status
    cond = "people.company_id = #{current_company_id} AND contract_start <= '#{Person.format_date(params[:employment_start])}' AND IF (contract_end IS NULL, '2099-01-01',contract_end) >= '#{Person.format_date(params[:employment_start])}'"
    unless @ids_person.blank?
      cond += " AND"
      cond += " person_id in ('#{@ids_person.join("','")}')"
    end unless cond.blank?
    @sortby, @direction = sort_column_status, sort_direction_status
    @page_num = page_num
    orderby = sort_column_status + " " + sort_direction_status if sort_column_status != "firstname"
    orderby = "firstname"+ " " + sort_direction_status + ",lastname"+ " " + sort_direction_status if sort_column_status == "firstname"
    @contracts = WorkContract.find(:all, :conditions => cond, :joins => "LEFT JOIN people ON people.id = work_contracts.person_id", :order => orderby).paginate :page => page_num, :per_page => 25
  end

  def prepare_accident
    cond = "accidents.company_id = #{current_company_id} and accidents.accident_category in ('Ringan','Berat','Sedang')"
    unless params[:tahun].blank?
      cond += " AND" unless cond.blank?
      cond += " YEAR(accidents.accident_date)='#{params[:tahun]}'"
    end
    unless params[:bulan].blank?
      cond += " AND" unless cond.blank?
      cond += " MONTH(accidents.accident_date)='#{params[:bulan]}'"
    end
    unless @ids_person.blank?
      cond += " AND" unless cond.blank?
      cond += " person_id in ('#{@ids_person.join("','")}')"
    end
    @sortby, @direction = sort_column_status, sort_direction_status
    @page_num = page_num
    orderby = sort_column_status + " " + sort_direction_status if sort_column_status != "firstname"
    orderby = "firstname"+ " " + sort_direction_status + ",lastname"+ " " + sort_direction_status if sort_column_status == "firstname"
    @accidents = Accident.find(:all, :conditions => cond, :joins => "LEFT JOIN people ON people.id = accidents.person_id", :order => orderby).paginate :page => page_num, :per_page => 25
  end

  def prepare_sp
      cond = "violations.company_id = #{current_company_id}"
    unless params[:tahun].blank?
      cond += " AND" unless cond.blank?
      cond += " (YEAR(violations.occurence_date)='#{params[:tahun]}' OR YEAR(violations.occurence_date)='#{params[:tahun]}')"
    end
    if !params[:bulan].blank?
      cond += " AND" unless cond.blank?
      cond += " (MONTH(violations.occurence_date)='#{params[:bulan]}' OR MONTH(violations.occurence_date)='#{params[:bulan]}')"
    end
    unless (params[:tahun].blank? && params[:bulan].blank?)
      unless @ids_person.blank?
        cond += " AND" unless cond.blank?
        cond += " person_id in ('#{@ids_person.join("','")}')"
      end
    end
    @sortby, @direction = sort_column_status, sort_direction_status
    @page_num = page_num
    orderby = sort_column_status + " " + sort_direction_status if sort_column_status != "firstname"
    orderby = "firstname"+ " " + sort_direction_status + ",lastname"+ " " + sort_direction_status if sort_column_status == "firstname"
    @violations = Violation.find(:all, :conditions => cond, :joins => "LEFT JOIN people ON people.id = violations.person_id", :order => orderby).paginate :page => page_num, :per_page => 25
  end

  def prepare_mutasi
    condition = "people.company_id = #{current_company_id}"
    join = ""
    unless params[:tahun].blank?
      condition += " AND" unless condition.blank?
      condition += " (YEAR(employments.employment_start)='#{params[:tahun]}' OR YEAR(employments.employment_end)='#{params[:tahun]}')"
    end
    if !params[:bulan].blank?
      condition += " AND" unless condition.blank?
      condition += " (MONTH(employments.employment_start)='#{params[:bulan]}' OR MONTH(employments.employment_end)='#{params[:bulan]}')"
    end

    unless params[:work_division_id].blank?
      condition += " AND" unless condition.blank?
      condition += " employments.work_division_id='#{params[:work_division_id]}'"
    end

    unless params[:position_id].blank?
      condition += " AND" unless condition.blank?
      condition += " employments.position_id='#{params[:position_id]}'"
    end

    unless params[:work_group_id].blank?
      condition += " AND" unless condition.blank?
      condition += " employments.work_group_id='#{params[:work_group_id]}'"
    end

    unless params[:contract_type_id].blank?
      condition += " AND" unless condition.blank?
      condition += " work_contracts.contract_type_id='#{params[:contract_type_id]}'"
    end
    
    condition += " AND " unless condition.blank?
    condition += "(employments.change_from_before='masuk kerja' or employments.change_from_before='terminasi')"
    @sortby, @direction = sort_column_status, sort_direction_status
    @page_num = page_num
    orderby = sort_column_status + " " + sort_direction_status if sort_column_status != "firstname"
    orderby = "firstname"+ " " + sort_direction_status + ",lastname"+ " " + sort_direction_status if sort_column_status == "firstname"
    @employments = Person.find(:all,:include=> [:employments], :conditions => condition, :order => orderby).paginate :page => page_num, :per_page => 25
  end

 def prepare_formasi
    ids_person = @person.collect{|x| x.id}
    kond = Person.str_kond_formasi(params, ids_person)
    unless kond.blank?
      emp = Employment.all(:conditions => kond, :include => :person)
      formasi_org = []
      if params[:filter] == "formasi"
        id_formasi = Employment.get_chart_formasi(ids_person, false)
        formasi_org = id_formasi[:person].flatten
      end
      if params[:filter] == "formasi_departemen"
        id_formasi = Employment.formasi_by_department(current_company_id, emp, false)
        formasi_org = id_formasi[:person].flatten
      end
      if params[:filter] == "formasi_bagian"
        id_formasi = Employment.formasi_by_division(current_company_id, emp, false)
        formasi_org = id_formasi[:person].flatten
      end
      if params[:filter] == "formasi_jabatan"
        id_formasi = Employment.formasi_by_position(current_company_id, emp, false)
        formasi_org = id_formasi[:person].flatten
      end#
      @page_num = page_num
      @formasi= formasi_org.paginate :page => page_num, :per_page => 25
    end
  end

  def prepare_absensi
    people_ids = Person.all(:select => :id, :include => [:employments], :conditions => Person.without_keluar_masuk).map(&:id).join(",")
    cond = "person_id in (#{people_ids}) AND company_id = '#{current_company_id}' AND is_holiday = 0"
    unless params[:work_division_id].blank?
      cond += " AND" unless cond.blank?
      cond += " division_id = #{params[:work_division_id]}"
    end
    unless params[:department_id].blank?
      cond += " AND" unless cond.blank?
      cond += " department_id = #{params[:department_id]}"
    end
    if !params[:tahun].blank? && !params[:bulan].blank?
      cond_date = "#{params[:tahun]}-#{params[:bulan]}-%"
    else
      if params[:tahun].blank? && !params[:bulan].blank?
        cond_date = "%-#{params[:bulan]}-%"
      elsif params[:bulan].blank? && !params[:tahun].blank?
        cond_date = "#{params[:tahun]}-%"
      end
    end
    cond += " AND date LIKE '#{cond_date}'" unless cond_date.nil?
    @sortby, @direction = sort_column_status, sort_direction_status
    @page_num = page_num
    orderby = "full_name"+ " " + sort_direction_status if sort_column_status == "full_name"
    @absences = PresenceReport.find(:all, :conditions => cond, :order => orderby).paginate :page => page_num, :per_page => 25
  end

  def sort_column_status
    !params[:sort].nil? && WorkContract.column_names.include?(params[:sort]) ? params[:sort] : "firstname"
  end

  def sort_direction_status
    !params[:direction].nil? && %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def page_num
    params[:page] || 1
  end

  def get_formasi_chart
    ids_person = @person.collect{|x| x.id}
    unless params[:filter].blank?
      data = Person.search_by_formasi(params, ids_person, current_company_id)
      @data_chart = data[:data_chart]
    end
  end

  def get_mutasi_chart
    unless params[:filter].blank?
      data = Person.search_by_mutasi(params)
      @data_chart = data[:data_chart]
    end
  end

  def get_promosi_chart
    promosi_chart = Gchart.line(
      :data => [10, 5, 5, 20, 13, 70, 34, 20,20,20,20,20],
      :axis_with_labels => 'x,y',
      :size => '800x300',
      :max_value => 100 ,
      :axis_labels => [['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Aug','Sep','Oct','Nov','Des'],[0,10,20,30,40,50,60,70,80,90,100]])
    @promosi_chart = promosi_chart
  end

  def get_status_chart
    ids_person = @person.collect{|x| x.id}
    @data_chart = ""
    unless params[:filter].blank?
      data = Person.search_by_status(params, ids_person, current_company_id)
      @contracts = data[:contract]
      @data_chart = data[:data_chart]
    end
  end

  def get_sp_chart
    ids_person = @person.collect{|x| x.id}
    data_chart = Person.search_by_sp(params, ids_person)
    @bln = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Aug','Sep','Oct','Nov','Des']
    if (!data_chart[:is_warning_nil] || !data_chart[:is_sp1_nil] || !data_chart[:is_sp2_nil] || !data_chart[:is_sp3_nil])
      @warning = data_chart[:warning]
      @sp1 = data_chart[:sp1]
      @sp2 = data_chart[:sp2]
      @sp3 = data_chart[:sp3]
    end
  end

  def get_accident_chart
    ids_person = @person.collect{|x| x.id}
    unless params[:filter].blank?
      @data_chart = Person.search_by_accident(params, ids_person)
    end
  end

  def get_absensi_chart
    unless params[:filter].blank?
      @absence_chart = Presence.absence_statistic_chart(params, current_company_id)
    end
  end

  def get_url_param_for_statistik(params)
    param = "filter="
    if ["formasi","formasi_jabatan","formasi_departemen","formasi_bagian"].include?(params[:txt_action])
      param = "filter=#{params[:txt_action]}"
      param << "&employment_start=#{params["filter_#{params[:txt_action]}"]['employment_start']}"
      param << "&work_division_id=#{params["filter_#{params[:txt_action]}"]['work_division_id']}" if params[:txt_action] != "formasi_bagian"
      param << "&department_id=#{params["filter_#{params[:txt_action]}"]['department_id']}"
    elsif params[:txt_action] == "mutasi"
      param = "filter=mutasi"
      param << "&tahun=#{params[:filter_mutasi]['tahun']}"
      param << "&contract_type_id=#{params[:filter_mutasi]['contract_type_id']}"
      param << "&gender=#{params[:filter_mutasi]['gender']}"
      param << "&bulan=#{params[:filter_mutasi]['bulan']}"
      param << "&position_id=#{params[:filter_mutasi]['position_id']}"
      param << "&work_division_id=#{params[:filter_mutasi]['work_division_id']}"
      param << "&work_group_id=#{params[:filter_mutasi]['work_group_id']}"
    elsif params[:txt_action] == "sp"
      param = "filter=sp"
      param << "&tahun=#{params[:filter_sp]['tahun']}"
      param << "&bulan=#{params[:filter_sp]['bulan']}"
    elsif params[:txt_action] == "accident"
      param = "filter=accident"
      param << "&tahun=#{params[:filter_accident]['tahun']}"
      param << "&bulan=#{params[:filter_accident]['bulan']}"
    elsif params[:txt_action] == "status"
      param = "filter=status"
      param << "&employment_start=#{params[:filter_status]['employment_start']}"
    elsif params[:txt_action] == "absensi"
      param = "filter=absensi"
      if params[:filter_absensi]
        param << "&tahun=#{params[:filter_absensi]['tahun']}"
        param << "&bulan=#{params[:filter_absensi]['bulan']}"
        param << "&work_division_id=#{params[:filter_absensi]['work_division_id']}"
        param << "&department_id=#{params[:filter_absensi]['department_id']}"
      end
    end
    return param
  end

  def action_for_render(filter_name,values,page_num,sortby,direction)
    render :update do |page|
      page.replace_html "content_#{filter_name}_table", :partial => "dashboard/list_#{filter_name}",
                                                :locals => {:values => values, :pagenum => page_num,
                                                            :sortby => sortby, :direction => direction}
      page.replace_html "pagination", :partial=> "formasi_paginate" if filter_name.include?("formasi")
      page << "$('#panelFilter#{filter_name}').attr('style','display: block;');"
      if values.total_entries > 0
        page << "$('.pagination').show();"
        page << "$('.paginationResult').attr('style','display: block;');"
        pagefirst = (values.total_entries >= 1) ? (((page_num.to_i - 1)*25)+1) : 0
        pagelast = (values.total_entries < (25*page_num.to_i) ? values.total_entries : 25*page_num.to_i)
        page << "$('#pagefirst#{filter_name}').html('#{pagefirst}');"
        page << "$('#pagelast#{filter_name}').html('#{pagelast}');"
        page << "$('#totalpage#{filter_name}').html('#{values.total_entries}');"
      else
        page << "$('.paginationResult').attr('style','display: none;');"
      end
      if values.total_pages > 1
        page << "$('.pagination').show();"
        page << "$('#prevPage#{filter_name}').attr('onClick','showResult#{filter_name}(#{values.previous_page || 1})');"
        page << "$('#nextPage#{filter_name}').attr('onClick','showResult#{filter_name}(#{values.next_page || values.total_pages})');"
        page << "$('#lastPage#{filter_name}').attr('onClick','showResult#{filter_name}(#{values.total_pages})');"
        page << "$('.pager').attr('style','display: block; float:right;');"
      else
        page << "$('.pager').attr('style','display: none;');"
      end
    end
  end

end

