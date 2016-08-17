class LeavesController < ApplicationController

  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :edit, :delete_multiple, :update_status]
  before_filter :prepare_index, :only => [:index]

  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('employee_leave_management_index') ? true : invalid_features
    when "new"
      current_features.include?('employee_leave_management_add') ? true : invalid_features
    when "edit"
      current_features.include?('employee_leave_management_edit') ? true : invalid_features
    when "delete_multiple"
      current_features.include?('employee_leave_management_delete') ? true : invalid_features
    when "update_status"
      current_features.include?('employee_leave_management_change_status') ? true : invalid_features
    end
    return true
  end

  def index
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Permintaan Cuti", "#leaves"
    reload_page("div_leaves", "list_leaves", "leaves", "ada")
  end

  def new
    @absence_types = AbsenceType.all(:conditions => ['company_id = ? AND (type_id = ? OR count_as_leave = ?)', current_company_id, 6, true])
    render :layout => false
  end

  def create
    @absence_types = AbsenceType.all(:conditions => ['company_id = ? AND (type_id = ? OR count_as_leave = ?)', current_company_id, 6, true])
    if params[:person]
      if (params[:date_start] <= params[:date_end])
        person = Person.find(params[:person_id]) if params[:person_id] != ""
        date_start = Date.parse(params[:date_start])
        date_end = Date.parse(params[:date_end])
        @error = false
        if (params[:date_start] != "") && (params[:date_end] != "") && !person.nil?
          (date_start..date_end).each do |date|
            @leave = person.employee_leaves.new(params[:leave])
            @leave.company_id = person.company_id
            @leave.leave_date = date
            if @leave.save && (params[:leave][:type_id] != "")
              @leave.create_absence(date, nil)
            else
              @error = true
            end
          end
        else
          @error = true
          @leave = EmployeeLeave.new(params[:leave])
          @leave.leave_date = params[:date_start] if (params[:date_start] != "") && (params[:date_end] != "")
          @leave.save
        end
        @leave.errors.add_to_base("Pilih alasan cuti") if (params[:leave][:type_id] == "")
        unless @error
          flash.now[:notice] = "Cuti berhasil ditambah!"
          prepare_index
          reload_page('leaves_div','index','leaves')
        else
          flash.now[:notice]="Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!"
          reload_page('leaves_div','new')
        end
      else
        flash.now[:notice]="Maaf ada kesalahan pada Periode Cuti. Mohon periksa kembali!"
        reload_page('leaves_div','new')
      end
    else
      flash.now[:notice]="Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!"
      reload_page('leaves_div','new')
    end
  end

  def edit
    @leave = EmployeeLeave.find(params[:id])
    @person = Person.find(@leave.person_id)
    @absence_types = AbsenceType.all(:conditions => ['company_id = ? AND (type_id = ? OR count_as_leave = ?)', current_company_id, 6, true])
    render :layout => false
  end

  def update
    unless params[:date_start].blank?
      params[:leave][:leave_date]=params[:date_start]
    end
    @leave = EmployeeLeave.find(params[:id])
    date = @leave.leave_date
    status = @leave.leave_status
    if @leave && @leave.update_attributes(params[:leave])
      @leave.create_absence(date, status)
      flash.now[:notice] = "Cuti berhasil diubah!"
      reload_page('leaves_div','index','leaves')
    else
      flash.now[:notice] = 'Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!'
      reload_page('leaves_div','edit')
    end
  end

  def update_employee_leave_quota
    @person = Person.find_by_id_and_company_id(params[:id], current_company_id)
    if @person
      @leave_quota = @person.current_leave_quota
      if @leave_quota
        join_leaves = NationalHoliday.join_leaves_count(@person.company_id, @leave_quota.start_date, @leave_quota.end_date)
        absences = @person.absences_for_period(@leave_quota.start_date.to_s(:db), @leave_quota.end_date.to_s(:db))
        leave_quota_used_counts = Absence.count_days_are_cut_employee_leave_quota(absences)
        
        quota_now = params[:person][:quota].to_i
        quota = quota_now + join_leaves + leave_quota_used_counts
        if quota_now == 0
          att = {:quota => quota, :out_of_quota => Date.today}
        elsif quota_now > 0
          att = {:quota => quota, :out_of_quota => nil}
        else
          att = {:quota => quota}
        end
      end

      if @leave_quota && @leave_quota.update_attributes(att)
        render :nothing => :true, :status => 200
      else
        render :nothing => :true, :status => 401
      end
    else
      render :nothing => :true, :status => 400
    end
  end

  def update_status
    flash.now[:notice] = "Cuti karyawan gagal diapprove!" if params[:act_name] == "approved"
    flash.now[:notice] = "Cuti karyawan gagal direject!" if params[:act_name] == "rejected"
    unless params[:ids].blank?
      leaves = EmployeeLeave.find(params[:ids])
      leaves.each do |leave|
        leaves_period = EmployeeLeave.find(:all, :conditions => ['person_id = ? AND created_at = ?', leave.person_id, leave.created_at])
        leaves_period.each do |l|
          l.update_attribute(:leave_status, params[:act_name])
          flash.now[:notice] = "Cuti karyawan berhasil diapprove!" if params[:act_name] == "approved"
          flash.now[:notice] = "Cuti karyawan berhasil direject!" if params[:act_name] == "rejected"
        end
      end
    end
    prepare_index
    reload_page("div_leaves", "list_leaves")
  end

  def delete_multiple
    flash.now[:notice] = "Cuti karyawan gagal dihapus!"
    unless params[:ids].blank?
      leaves = EmployeeLeave.find(params[:ids])
      leaves.each do |leave|
        leave.delete_data
        flash.now[:notice] = "Cuti karyawan berhasil dihapus!"
      end
    end
    prepare_index
    reload_page("div_leaves", "list_leaves")
  end

  def get_employee
    company_id = current_company_id
    @people = Person.find(:all, :conditions => "company_id = #{company_id} and latest_employment_id is not null")
    respond_to do |format|
      format.xml
    end
  end

  protected

  def prepare_index
    @per_page = 15
    @leaves = EmployeeLeave.paginate(:conditions => ['company_id = ?', current_company_id], :group => 'leave_date', :order => "created_at DESC, leave_date DESC", :page => params[:page], :per_page => @per_page)
  end

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name, :object => @leaves
          page << "$('.loading-btn').hide"
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

end
