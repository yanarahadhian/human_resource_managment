class SchedulesController < ApplicationController
  add_breadcrumb "Penjadwalan", "#schedules"
  ssl_required :check_features, :layout_schedule, :search_employee, :check, :change_table, :change_group_selector, :change_table_group, :find_group, :search_and_delete
  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :edit, :destroy]
  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('schedule_index') ? true : invalid_features
    when "new"
      current_features.include?('schedule_new') ? true : invalid_features
    when "edit"
      current_features.include?('schedule_edit') ? true : invalid_features
    when "destroy"
      current_features.include?('schedule_delete') ? true : invalid_features
    end
    # return true
  end

  def index    
    #@work_groups = WorkGroup.find(:all, :conditions => ["company_id = ? AND division_id = ?",current_company_id,division.id])
    prepare_index
    reload_page('the_list','list_schedules')
  end

  def new
    add_breadcrumb "Susun Jadwal Kerja", "#schedules/new"
    @wg = WorkGroup.by_company(current_company_id).all(:order => "work_group_name ASC")
    @divisions = Division.all(:conditions =>['company_id = ?', current_company_id], :order => "name ASC")
    render :layout => false
  end

  def layout_schedule
    render :layout => "application_setting"
  end

  def search_employee
    @people = Person.find(:all, :conditions => ["firstname like ? and company_id = ?",
        "%"+ params['name'].to_s + "%" , current_user.company_id])
  end

  def create
    @employee_ids = params["emp_ids"].to_a unless params["emp_ids"].blank?
    @people = Person.find(:all, :conditions => {:id => @employee_ids})
    options = get_options
    @people.each do |person|
      employment = person.current_employment
      employee_shift = EmployeeShift.find(:last,
        :conditions => ['person_id = ? AND shift_to = ? AND shift_from = ?', person.id, options[:shift_to], options[:shift_from]])
      options[:work_group_id] = employment.work_group_id unless employment.blank?
      options[:person_id] = person.id
      options[:is_active] = true
      EmployeeShift.insert_employee_shift(employee_shift, options)
    end
    flash.now[:notice] = "Data schedules berhasil disimpan"

    # Update Presence Reports
    employee_shifts = EmployeeShift.all(:conditions=> ['is_active = true AND company_id = ? AND shift_id = ? AND shift_to = ? AND shift_from = ?', current_company_id, options[:shift_id], options[:shift_to], options[:shift_from]])
    PresenceReport.update_by_shift(employee_shifts)
    prepare_index
    reload_page('index','index_partial', 'schedules')
    #redirect_to schedules_path
  end

  def update
    employee_ids = params["emp_ids"].to_a unless params["emp_ids"].blank?
    @people = Person.find(:all, :conditions => {:id => employee_ids})
    options = get_options
    kond = "shift_to = '#{options[:shift_to].strftime("%Y-%m-%d")}' AND shift_from = '#{options[:shift_from].strftime("%Y-%m-%d")}' AND shift_id=#{options[:shift_id]}"
    remove_person_on_schedule(kond)

    @people.each do |person|
      employment = person.current_employment
      employee_shift = EmployeeShift.find(:last,:conditions => "person_id = #{person.id} AND #{kond}")
      options[:work_group_id] = employment.work_group_id unless employment.blank?
      options[:person_id] = person.id
      options[:is_active] = true
      EmployeeShift.insert_employee_shift(employee_shift, options)
    end
    flash.now[:notice] = "Data Schedules Berhasil diperbarui"
    # Update Presence Reports
    employee_shifts = EmployeeShift.all(:conditions=> ['company_id = ? AND shift_id = ? AND shift_to = ? AND shift_from = ?', current_company_id, options[:shift_id], options[:shift_to], options[:shift_from]])
    PresenceReport.update_by_shift(employee_shifts)
    prepare_index
    reload_page('index','index_partial', 'schedules')
  end

  def change_table
    @employeeshifts = EmployeeShift.find(:all, :conditions=>['shift_id = ? and shift_from = ? and shift_to = ?', params['value'], params['start'],params['end']] )
    employee_ids = @employeeshifts.map(&:person_id)
    @people = Person.find(:all, :conditions => {:id => employee_ids})
    render :layout => false
  end

  def change_group_selector
    if params[:value].blank?
      @wg = WorkGroup.find(:all, :conditions =>['company_id = ? ', current_company_id])
    else
      @wg = WorkGroup.find(:all, :conditions =>['company_id = ? and division_id = ?', current_company_id, params['value']])
    end

    unless params['value'].blank?
      @division = Division.find(params['value'])
    end
    render :layout => false
  end

  def change_table_group
    @people =  Employment.person_by_work_group(params, current_company_id)
    render :layout => false
  end

  def find_group
    @findgroup = Person.find(:first, :conditions=>['firstname = ? and company_id = ?', params['value'], current_company_id])
  end

  def edit
    add_breadcrumb "Edit Jadwal Kerja", "#sch/edit/#{params[:id]}?start=#{params[:start]}&end=#{params[:end]}"
    kond = "shift_id = #{params['id']} AND shift_from = '#{params['start']}' AND shift_to = '#{params['end']}' AND company_id = #{current_company_id}" # AND is_active = true"
    @schedules = EmployeeShift.all(:conditions => kond)
    employee_ids = @schedules.map(&:person_id)
    @people = Person.find(employee_ids, :order => "firstname")
    @divisions = Division.find(:all, :conditions =>['company_id = ?', current_company_id], :order => "name ASC")
    @wg = WorkGroup.by_company(current_company_id).all(:order => "work_group_name ASC")
    render :layout => "false"
  end

  def search_and_delete
    @person = Person.find(params['emp_name'])
    render :layout => false
  end


  def groups_by_division
    @work_groups = params[:id].present? ? Division.find(params[:id]).work_groups.all(:order => "work_group_name") :
      WorkGroup.all(:conditions => {:company_id => current_company_id}, :order => "name")

    respond_to do |format|
      format.js
    end
  end

  private

  def get_options
    options = {}
    options[:company_id] = current_company_id
    options[:shift_from] = Date.parse(params['first_start'])
    options[:shift_to] = Date.parse(params['first_end'])
    options[:shift_id] = params['schedule']['shift_id'].to_i
    return options
  end

  def remove_person_on_schedule(kond)
    kond =  "#{kond}"
    kond += " AND person_id not in (#{@people.map(&:id).join(",")})" unless @people.blank?
    employee_shift = EmployeeShift.find(:all,:conditions => kond)
    employee_shift.each do |x|
      x.delete
    end
  end

  def prepare_index
    @shifts = Shift.find_all_by_company_id(current_company_id)
    @divisions = Division.find_all_by_company_id(current_company_id, :order => "name ASC")
    @work_groups = WorkGroup.find_all_by_company_id(current_company_id, :order => "work_group_name ASC")
    
    @per_page = 30
    person_kond = get_first_condition
    if is_filter
      kond = EmployeeShift.search_filter(params[:filter], current_company_id)
      kond << "#{person_kond}" unless person_kond.blank?
      @schedulelist = EmployeeShift.paginate(:conditions => kond, :page => params[:page], :per_page => @per_page)
    else
      first_kond = "#{person_kond}" unless person_kond.blank?
      @schedulelist = EmployeeShift.paginate(:conditions=> "company_id = #{current_company_id} #{first_kond}", :order => "shift_from DESC", :page => params[:page], :per_page => @per_page)
    end
    @schedulelist_all = EmployeeShift.all(:conditions=> "company_id = #{current_company_id}")
  end

  def is_filter
    unless (params['filter'].blank?) || (params['filter']['periode_start'].blank? &&
        params['filter']['nama_shift'].blank? && params['filter']['nama_karyawan'].blank? &&
        params['filter']['periode_end'].blank? && params['filter']['nama_bagian'].blank?)
      return true;
    else
      return false;
    end
  end

  def get_first_condition
    first_kond = Person.without_keluar_masuk + "AND people.company_id=#{current_company_id}"
    person = Person.all(:select => "person.id",:include=> [:employments], :conditions => first_kond)
    unless person.blank?
      person_id = person.collect{|x| x.id}
      return "AND person_id in (#{person_id.join(",")})"
    else
      return ""
    end
  end

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name, :object => @schedulelist          
          page.replace_html "notification", :partial=> "layouts/shared/notification" if HrSetting.is_notification_action(params)
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def load_page(div_name, page_name)
    render :update do |page|
      page.replace_html div_name, :partial=> page_name
    end
  end

end

