class ShiftsController < ApplicationController

  ssl_required :check_features, :karyawan
  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :edit, :destroy]
  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('shift_index') ? true : invalid_features
    when "new"
      current_features.include?('shift_new') ? true : invalid_features
    when "edit"
      current_features.include?('shift_edit') ? true : invalid_features
    when "destroy"
      current_features.include?('shift_delete') ? true : invalid_features
    end
    # return true
  end

  def index
    add_breadcrumb "Shifts", "#shifts"
    prepare_index
    reload_page('index','index_partial','shifts')
  end

  def show
    render :layout => "application_setting"
  end

  def new
    @hr = HrSetting.find(:first , :conditions => ['company_id = ?', current_company_id])
    add_breadcrumb "Shifts", "#shifts"
    add_breadcrumb "Tambah Shifts", "#shifts/new"
    render :layout => false
  end

  def edit
    @hr = HrSetting.find(:first , :conditions => ['company_id = ?', current_company_id])
    @work_time = Shift.find(:first , :conditions => ['id = ? and company_id = ? ', params['id'], current_company_id ])

    if @work_time
      add_breadcrumb "Shifts", "#shifts"
      add_breadcrumb "Edit Shifts", "#sh/edit/#{@work_time.id}"
      render :layout => false
    else
      render :nothing => true
    end
  end


  def update
    total_hours = 0
    @work_time = Shift.find(:first , :conditions => ['id = ? and company_id = ? ', params['id'], current_company_id ])
    if @work_time and @work_time.update_attributes(prepare_data_shift)
      PresenceReport.update_by_shift(@work_time)
      for i in 1..7
        id = Shift.get_id_work_time(@work_time, i)
        @update_work_time = WorkTime.find(:first, :conditions => ['id = ?', id])
        unless params["c#{i}"] == "vacation"
          total_hours = total_hours + get_data_and_save_work_time(i)
        else
          total_hours = total_hours + get_data_blank_and_save_work_time(i)
        end
      end
      @work_time.update_attributes(:total_hours => total_hours)
      flash.now[:notice] = "Data shift berhasil diupdate"
      prepare_index
      reload_page('index','index_partial','shifts')
    else
      flash.now[:notice] = "Data Shift gagal diupdate"
      reload_page('index','edit_partial')
    end
  end

  def shift_karyawan
    render :layout => "application_setting"
  end

  def create
    @shift = Shift.new(prepare_data_shift)
    @shift.company_id = current_company_id
    error = false
    total_hour = 0
    for j in 1..7
      start_time = "00:00"
      end_time = "00:00"
      unless(params["c#{j}"] == 'vacation')
        start_time = params["post"]["start_time_#{j}(4i)"] + ":" +params["post"]["start_time_#{j}(5i)"]
        end_time = params["post"]["end_time_#{j}(4i)"]  + ":" + params["post"]["end_time_#{j}(5i)"]
      end
      @work_time = WorkTime.new(params['work_time'])
      @work_time.company_id = current_company_id
      time_cal = Shift.calculate_length_in_hours(start_time, end_time, params["break_#{j}"], params['break_choice'])
      @work_time.start_time = (Time.parse(start_time)).strftime("%H %M %S")
      @work_time.end_time = (Time.parse(end_time)).strftime("%H %M %S")
      @work_time.break_length_in_minutes = time_cal[:break_length_in_minutes]
      @work_time.break_per_hour_in_minutes = time_cal[:break_per_hour_in_minutes]
      @work_time.length_in_hours  = time_cal[:length_in_hours]
      @work_time.compulsory_overtime_in_minutes = params["compulsory_#{j}"]
      @work_time.length_in_hours  = @work_time.length_in_hours - (params["compulsory_#{j}"].to_f / 60)
      total_hour = total_hour + @work_time.length_in_hours
      if @work_time.save
        id = WorkTime.find(:last).id
        Shift.set_worktime_id_to_shift(@shift,id, j)
      else
        error = true
      end
    end
    if error
      flash.now[:notice] = "Mohon mengisi data yang diperlukan"
      @hr = HrSetting.find(:first , :conditions => ['company_id = ?', current_company_id])
      reload_page('index','new_partial')
    else
      @shift.total_hours = total_hour
      if @shift.save
        flash.now[:notice] = "Data shift berhasil disimpan"
        prepare_index
        reload_page('index','index_partial','shifts')
      else
        flash.now[:notice] = "Mohon mengisi data yang diperlukan"
        reload_page('index','new_partial')
      end
    end
  end

  def delete_multiple
    flash.now[:notice] = "Data shift gagal Dihapus"
    unless params[:ids].blank?
      valid = true
      s = Shift.all(:conditions => "id in ('#{params[:ids].join("','")}') and company_id = #{current_company_id}")
      flash.now[:notice] = "Data shift "
      s.each do |f|
        unless f.destroy
          valid = false
          flash.now[:notice] << "#{f.shift_name}, "
        end
      end
      flash.now[:notice] << "gagal dihapus karena memiliki data jadwal"
      flash.now[:notice] = "Data shift berhasil dihapus" if valid
    end
    prepare_index
    reload_page('index','index_partial','shifts')
  end

  private

  def prepare_index
    @per_page = 10
    @shift = Shift.paginate(:conditions => ['company_id = ?', current_company_id], :page => params[:page], :per_page => @per_page)
  end

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name
          page.replace_html "notification", :partial=> "layouts/shared/notification" if HrSetting.is_notification_action(params)
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def prepare_data_shift
    {:shift_name => params['shift_name'],
      :shift_category => params['shift_category'],
      :shift_code => params['shift_code'],
      :break_choice => params['break_choice'],
      :working_hour_per_week => params['working_hour_per_week']}
  end

  def get_data_and_save_work_time(sort)
    start_time = params["post"]["start_time_#{sort}(4i)"] + ":" +params["post"]["start_time_#{sort}(5i)"]
    end_time = params["post"]["end_time_#{sort}(4i)"]  + ":" + params["post"]["end_time_#{sort}(5i)"]
    time_cal = Shift.calculate_length_in_hours(start_time, end_time, params["break_#{sort}"], params['break_choice'])
    length_in_hours = time_cal[:length_in_hours] - (params["compulsory_#{sort}"].to_f / 60)
    data_work_time = {:start_time => (Time.parse(start_time)).strftime("%H %M %S"),
      :end_time => (Time.parse(end_time)).strftime("%H %M %S"),
      :length_in_hours => length_in_hours,
      :break_length_in_minutes => time_cal[:break_length_in_minutes],
      :break_per_hour_in_minutes => time_cal[:break_per_hour_in_minutes],
      :compulsory_overtime_in_minutes => params["compulsory_#{sort}"]}
    save_work_time(data_work_time, sort)
    return length_in_hours
  end

  def get_data_blank_and_save_work_time(sort)
    start_time = "00:00"
    end_time = "00:00"
    data_work_time = {:start_time => (Time.parse(start_time)).strftime("%H %M %S"),
      :end_time => (Time.parse(end_time)).strftime("%H %M %S"),
      :length_in_hours => 0,
      :break_length_in_minutes => 0,
      :break_per_hour_in_minutes => 0,
      :compulsory_overtime_in_minutes => params["compulsory_#{sort}"]}
    save_work_time(data_work_time, sort)
    return 0
  end

  def save_work_time(data_work_time, sort)
    unless @update_work_time.nil?
      @update_work_time.update_attributes(data_work_time)
    else
      @update_work_time = WorkTime.new(data_work_time)
      @update_work_time.save
      @update_work_time = WorkTime.find(:last)
      id = @update_work_time.id
      Shift.set_worktime_id_to_shift(@work_time,id, sort)
      @update_work_time.save
    end
  end

end
