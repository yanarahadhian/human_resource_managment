class AbsencesController < ApplicationController
  before_filter :login_required
  before_filter :current_company_person
  before_filter :filter_options
  before_filter :start_end_date, :only => [:daily_index_table, :late_table, :more_hour_table,
    :less_hour_table, :more_rest_table, :less_rest_table, :fix_presence,
    :absent_table, :presence_report, :presence_report_table, :absence_report_table, :export_presence_report_xls,
    :list_presence_report, :no_logout_table]
  before_filter :start_end_month, :only => [:monthly_index_table, :mine]
  before_filter :start_end_month1, :only => [:my_monthly_absence, :my_monthly_absence_table]

  ssl_required :check_features, :monthly_index_table, :daily_index_table, :fix_presences, :late,
    :late_table, :override_popup, :override_late, :more_hour, :more_hour_table, :more_hour_popup,
    :more_hour_action, :less_hour, :less_hour_table, :less_hour_popup, :less_hour_action, :more_rest,
    :more_rest_table, :more_rest_popup, :more_rest_action, :less_rest, :less_rest_table, :less_rest_action,
    :absent, :absent_table, :absent_popup, :absent_action, :new_absent, :no_logout, :no_logout_table,
    :no_logout_popup, :no_logout_action, :my_absence, :my_monthly_absence, :my_monthly_absence_table,
    :my_yearly_absence, :mine, :redeem_leaves, :presence_report, :export_presence_report_xls,
    :employee_present, :start_work, :end_work, :fingerprint_data_import, :divisions_by_department

  before_filter :current_features
  before_filter :check_features, :only => [:index, :employee_present, :my_absence, :presence_report, :late,
    :more_hour, :less_hour, :more_rest, :less_rest, :absent, :no_logout]
  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('present_index') ? true : invalid_features
    when "employee_present"
      current_features.include?('present_employee') ? true : invalid_features
    when "my_absence"
      current_features.include?('present_detail') ? true : invalid_features
    when "presence_report"
      current_features.include?('present_report') ? true : invalid_features

      # Terlambat tab
    when "late"
      current_features.include?('late_index') ? true : invalid_features
    when "override_late"
      current_features.include?('override') ? true : invalid_features
    when "show"
      current_features.include?('late_detail') ? true : invalid_features

      # Jam Kerja Lebih tab
    when "more_hour"
      current_features.include?('working_hours_more_index') ? true : invalid_features

      # Jam Kerja Kurang tab
    when "less_hour"
      current_features.include?('working_hours_less_index') ? true : invalid_features

      # Istirahat Lebih tab
    when "more_rest"
      current_features.include?('less_rest_index') ? true : invalid_features

      # Istirahat Kurang tab
    when "less_rest"
      current_features.include?('more_rest_index') ? true : invalid_features

      # Tidak Masuk tab
    when "absent"
      current_features.include?('absence_index') ? true : invalid_features

      # Tidak Lengkap tab
    when "no_logout"
      current_features.include?('employee_no_end_work_time_index') ? true : invalid_features
    end
    # return true
  end

  def index
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Absensi Kerja", "#absences"
    render :layout => false
  end

  def monthly_index_table
    @options[:person] = true
    @total_presences = Presence.who_is_working(current_company_id, @date_start, @date_end, @options)
    set_data_to_session("monthly_index_table")
    @presences = @total_presences
    case params[:iSortCol_0].to_i
    when 1
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| y.full_name <=> x.full_name } : @presences.sort{|x,y| x.full_name <=> y.full_name }
    when 2
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| (y.department(@date_end) ? y.department(@date_end).department_name.upcase : "") <=> (x.department(@date_end) ? x.department(@date_end).department_name.upcase : "") } : @presences.sort_by{|x| (x.department(@date_end) ? x.department(@date_end).department_name.upcase : "") }
    when 3
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| (y.division(@date_end) ? y.division(@date_end).name.upcase : "") <=> (x.division(@date_end) ? x.division(@date_end).name.upcase : "") } : @presences.sort_by{|x| (x.division(@date_end) ? x.division(@date_end).name.upcase : "") }
    when 4
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| y.presences.total_attendance_days(@date_start.month, @date_start.year) <=> x.presences.total_attendance_days(@date_start.month, @date_start.year) } : @presences.sort_by{|x| x.presences.total_attendance_days(@date_start.month, @date_start.year) }
    when 5
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| y.absences.total_by_type([1,2,5,6], @date_start, @date_end, current_company_id) <=> x.absences.total_by_type([1,2,5,6], @date_start, @date_end, current_company_id) } : @presences.sort_by{|x| x.absences.total_by_type([1,2,5,6], @date_start, @date_end, current_company_id) }
    when 6
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| y.absences.total_by_type([3,7], @date_start, @date_end, current_company_id) <=> x.absences.total_by_type([3,7], @date_start, @date_end, current_company_id) } : @presences.sort_by{|x| x.absences.total_by_type([3,7], @date_start, @date_end, current_company_id) }
    when 7
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| y.absences.total_by_type([4], @date_start, @date_end, current_company_id) <=> x.absences.total_by_type([4], @date_start, @date_end, current_company_id) } : @presences.sort_by{|x| x.absences.total_by_type([4], @date_start, @date_end, current_company_id) }
    else
    end
    @presences = @presences[ (@start_index) .. (@start_index + @display_length - 1) ]
    @iTotalRecords = @total_presences.count
    @iTotalDisplayRecords = @presences.count
    @sEcho = params[:sEcho].to_i
    render :partial => 'absences/table/monthly_index_table'
  end

  def daily_index_table
    @total_presences = Presence.who_is_working(current_company_id, @date_start, @date_end, @options)
    @presences_all_count = Presence.all(:conditions => ["company_id = ?", current_company_id], :limit => 1).count#Presence.who_is_working(current_company_id, nil, nil, @options).count
    set_data_to_session("absences")
    @presences = @total_presences
    case params[:iSortCol_0].to_i
    when 1
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| y.person.full_name <=> x.person.full_name } : @presences.sort_by{|x| x.person.full_name}
    when 2
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| (y.person.department(@date_end) ? y.person.department(@date_end).department_name.upcase : "") <=> (x.person.department(@date_end) ? x.person.department(@date_end).department_name.upcase : "") } : @presences.sort_by{|x| (x.person.department(@date_end) ? x.person.department(@date_end).department_name.upcase : "") }
    when 3
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| (y.person.division(@date_end) ? y.person.division(@date_end).name.upcase : "") <=> (x.person.division(@date_end) ? x.person.division(@date_end).name.upcase : "") } : @presences.sort_by{|x| (x.person.division(@date_end) ? x.person.division(@date_end).name.upcase : "") }
    when 4
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| y.presence_details.first.start_working <=> x.presence_details.first.start_working } : @presences.sort_by{|x| x.presence_details.first.start_working }
    when 5
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| y.presence_details.last.end_working.to_i <=> x.presence_details.last.end_working.to_i } : @presences.sort_by{|x| x.presence_details.last.end_working.to_i }
    when 6
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| y.break_length_in_minutes.to_i <=> x.break_length_in_minutes.to_i } : @presences.sort_by{|x| x.break_length_in_minutes.to_i }
    when 7
      @presences = params[:sSortDir_0].upcase == "DESC" ? @presences.sort{|x,y| y.presence_length_in_hours.to_f <=> x.presence_length_in_hours.to_f } : @presences.sort_by{|x| x.presence_length_in_hours.to_f }
    else
    end
    @presences = @presences[ (@start_index) .. (@start_index + @display_length - 1) ]
    @iTotalRecords = @total_presences.count
    @iTotalDisplayRecords = @presences.count
    @sEcho = params[:sEcho].to_i
    render :partial => 'absences/table/daily_index_table'
  end

  def show
    render :layout => "application2"
  end

  def fix_presences
    @presences = Presence.who_is_working(current_company_id, @date_start, @date_end, @options)
    if @presences
      @presences.each do |presence|
        presence.moving_details
      end
    end
    render :nothing => :true, :status => 200
  end

  def delete_presences
    @presence_ids = params[:presence_ids].to_a
    @presences = Presence.all(:conditions => {:id => @presence_ids})
    unless @presences.blank?
      names = []
      date = @presences.first.presence_date
      @presences.each do |presence|
        if presence.destroy
          names << presence.person.full_name
        end
      end
      flash.now[:notice] = "Kehadiran karyawan #{names.to_sentence} pada tanggal #{date.strftime("%d/%m/%Y")} berhasil dihapus"
    end
    respond_to do |format|
      format.html { redirect_to("#{current_root_url}#absences") }
      format.js { render :text => flash.now[:notice] }
    end
  end
  # Late Tab =====================================================================

  def late
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Terlambat", "#late"
    render :layout => false
  end

  def late_table
    @total_lates = Presence.late_comers(current_company_id, @date_start, @date_end, @options)
    @total_lates_all = Presence.all(:conditions => ["company_id = ?", current_company_id]).index{|x| x.is_late}.to_i#Presence.late_comers(current_company_id, nil, nil, @options).count
    set_data_to_session("late")
    @lates = @total_lates
    case params[:iSortCol_0].to_i
    when 1
      @lates = params[:sSortDir_0].upcase == "DESC" ? @lates.sort{|x,y| y[:person_name].upcase <=> x[:person_name].upcase } : @lates.sort_by{|x| x[:person_name].upcase}
    when 2
      @lates = params[:sSortDir_0].upcase == "DESC" ? @lates.sort{|x,y| (y[:department] ? y[:department].department_name.upcase : "") <=> (x[:department] ? x[:department].department_name.upcase : "") } : @lates.sort_by{|x| (x[:department] ? x[:department].department_name.upcase : "") }
    when 3
      @lates = params[:sSortDir_0].upcase == "DESC" ? @lates.sort{|x,y| (y[:division] ? y[:division].name.upcase : "") <=> (x[:division] ? x[:division].name.upcase : "") } : @lates.sort_by{|x| (x[:division] ? x[:division].name.upcase : "") }
    when 4
      @lates = params[:sSortDir_0].upcase == "DESC" ? @lates.sort{|x,y| y[:shift_name] <=> x[:shift_name] } : @lates.sort_by{|x| x[:shift_name] }
    when 5
      @lates = params[:sSortDir_0].upcase == "DESC" ? @lates.sort{|x,y| y[:date] <=> x[:date] } : @lates.sort_by{|x| x[:date] }
    when 7
      @lates = params[:sSortDir_0].upcase == "DESC" ? @lates.sort{|x,y| y[:late_time] <=> x[:late_time] } : @lates.sort_by{|x| x[:late_time] }
    else
    end
    @lates = @lates[ (@start_index) .. (@start_index + @display_length - 1) ]
    @iTotalRecords = @total_lates.count
    @iTotalDisplayRecords = @lates.count
    @sEcho = params[:sEcho].to_i
    render :partial => 'absences/table/late_table'
  end

  def override_popup
    @presence_ids = params[:presence_ids]
    @presence = Presence.find(@presence_ids[0].to_i)
    render :partial => 'absences/popup_pages/popup_late'
  end

  def override_late
    @presence_ids = params[:presence_ids].to_a
    if @presence_ids and Presence.is_presence_ids_belongs_to_current_company?(@presence_ids, current_company_id)
      lateness = params[:late]
      late_reason = params[:reason]
      same_all = params[:same_all]
      if same_all == "false"
        @presence = Presence.find(@presence_ids[0].to_i)
        unless lateness.blank?
          lateness_in_minutes = lateness.to_i
          @presence.presence_details.first.override_lateness(lateness_in_minutes, late_reason)
        else
          @presence.presence_details.first.override_lateness(-1, late_reason)
        end
      else
        @presences = Presence.find(:all, :conditions => {:id => @presence_ids})
        @presences.each do |@presence|
          unless lateness.blank?
            lateness_in_minutes = lateness.to_i
            @presence.presence_details.first.override_lateness(lateness_in_minutes, late_reason)
          else
            @presence.presence_details.first.override_lateness(-1, late_reason)
          end
        end
      end
      flash.now[:notice] = "Keterlambatan karyawan berhasil di-override"
      respond_to do |format|
        format.html { redirect_to :action => 'late', :layout => false }
        format.js { render :text => flash.now[:notice] }
      end
    else
      render :nothing => true
    end
  end

  # Work Time More ===============================================================

  def more_hour
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Kerja Lebih", "#more_hour"
    render :layout => false
  end

  def more_hour_table
    @total_more_hours = Presence.worktime_more_than_normal(current_company_id, @date_start, @date_end, @options)
    @total_more_hours_all = Presence.all(:conditions => ["company_id = ?", current_company_id], :limit => 1).count#Presence.worktime_more_than_normal(current_company_id, nil, nil, @options).count
    set_data_to_session("more_hour")
    @more_hours = @total_more_hours
    case params[:iSortCol_0].to_i
    when 1
      @more_hours = params[:sSortDir_0].upcase == "DESC" ? @more_hours.sort{|x,y| y[:person_name].upcase <=> x[:person_name].upcase } : @more_hours.sort_by{|x| x[:person_name].upcase}
    when 2
      @more_hours = params[:sSortDir_0].upcase == "DESC" ? @more_hours.sort{|x,y| (y[:department] ? y[:department].upcase : "") <=> (x[:department] ? x[:department].upcase : "") } : @more_hours.sort_by{|x| (x[:department] ? x[:department].upcase : "") }
    when 3
      @more_hours = params[:sSortDir_0].upcase == "DESC" ? @more_hours.sort{|x,y| (y[:division] ? y[:division].upcase : "") <=> (x[:division] ? x[:division].upcase : "") } : @more_hours.sort_by{|x| (x[:division] ? x[:division].upcase : "") }
    when 4
      @more_hours = params[:sSortDir_0].upcase == "DESC" ? @more_hours.sort{|x,y| y[:date] <=> x[:date] } : @more_hours.sort_by{|x| x[:date] }
    when 7
      @more_hours = params[:sSortDir_0].upcase == "DESC" ? @more_hours.sort{|x,y| y[:work_length] <=> x[:work_length] } : @more_hours.sort_by{|x| x[:work_length] }
    else
    end
    @more_hours = @more_hours[ (@start_index) .. (@start_index + @display_length - 1) ]
    @iTotalRecords = @total_more_hours.count
    @iTotalDisplayRecords = @more_hours.count
    @sEcho = params[:sEcho].to_i
    render :partial => 'absences/table/more_hour_table'
  end

  def more_hour_popup
    presence_ids = params[:presence_ids]
    if !presence_ids.blank? and Presence.is_presence_ids_belongs_to_current_company?(presence_ids, current_company_id)
      @popup_id = params[:popup_id].to_i
      @presence = Presence.more_less_worktime(presence_ids[0].to_i)
      @hr_setting = HrSetting.find(:last, :conditions => ['company_id = ?', current_company_id])
      @minutes, @hours = [], []
      if !@hr_setting.nil? && @presence
        for i in 0..@presence[:more_hour].to_i
          @hours << i
        end
        last_num = 0
        while last_num < 60
          @minutes << last_num
          last_num += @hr_setting.period_in_minutes.to_i
        end
      end
      render :partial => 'absences/popup_pages/popup_more_hour', :layout => false
    end
  end

  def more_hour_action
    presence_ids = params[:presence_ids].to_a
    if !presence_ids.blank? and Presence.is_presence_ids_belongs_to_current_company?(presence_ids, current_company_id)
      @popup_id = params[:popup_id].to_i
      @presence = Presence.more_less_worktime(presence_ids[0].to_i)
      duration = params[:more].blank? ? 0 : get_duration_in_hour(params[:more])
      case @popup_id
      when 1
        same_all = params[:same_all]
        unless same_all == "true"
          @more = Presence.find(presence_ids[0].to_i)
          if duration <= @presence[:more_hour] && @more.more_hour_as_overtime(duration,params[:overtime_type])
            flash.now[:notice] = "Kelebihan kerja karyawan berhasil dianggap lembur"
          else
            flash.now[:notice] = "Kelebihan kerja karyawan tidak berhasil dianggap lembur"
          end
        else
          presence_ids.each do |presence_id|
            @more = Presence.find(presence_id)
            @presence = Presence.more_less_worktime(presence_id.to_i)
            @more.more_hour_as_overtime(duration,params[:overtime_type]) if duration <= @presence[:more_hour]
          end
        end
      when 2
        unless params["date_change"].blank?
          same_all = params[:same_all]
          unless same_all == "true"
            date_change = Date.parse(params[:date_change])
            @more = Presence.find(presence_ids[0].to_i)
            @more.work_in_another_day(date_change,duration)
          else
            presence_ids.each do |presence_id|
              date_change = Date.parse(params[:date_change])
              @more = Presence.find(presence_id)
              @more.work_in_another_day(date_change,duration)
            end
          end
          flash.now[:notice] = "Kelebihan kerja karyawan berhasil dianggap kerja dihari lain"
        else
          flash.now[:notice] = "Kelebihan kerja karyawan tidak berhasil dianggap kerja dihari lain"
        end
      else
        @more = Presence.find(:all, :conditions => { :id => presence_ids})
        success = []
        @more.each do |presence|
          success << presence if presence.ignore_more_work
        end
        flash.now[:notice] =  (success.length == @more.length) ? "Kelebihan kerja karyawan berhasil diabaikan" : "Kelebihan kerja karyawan tidak berhasil diabaikan. Silahkan periksa kembali Penjadwalan karyawan tersebut."
      end
    end
    respond_to do |format|
      format.html { redirect_to :action => 'more_hour', :layout => false }
      format.js { render :text => flash.now[:notice] }
    end
  end

  # Work Time Less ===============================================================
  def less_hour
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Kerja Kurang", "#less_hour"
    render :layout => false
  end

  def less_hour_table
    @total_less_hours = Presence.worktime_less_than_normal(current_company_id, @date_start, @date_end, @options)
    @total_less_hours_all = Presence.all(:conditions => ["company_id = ?", current_company_id], :limit => 1).count#Presence.worktime_less_than_normal(current_company_id, nil, nil, @options).count
    set_data_to_session("less_hour")
    @less_hours = @total_less_hours
    case params[:iSortCol_0].to_i
    when 1
      @less_hours = params[:sSortDir_0].upcase == "DESC" ? @less_hours.sort{|x,y| y[:person_name].upcase <=> x[:person_name].upcase } : @less_hours.sort_by{|x| x[:person_name].upcase}
    when 2
      @less_hours = params[:sSortDir_0].upcase == "DESC" ? @less_hours.sort{|x,y| (y[:department] ? y[:department].upcase : "") <=> (x[:department] ? x[:department].upcase : "") } : @less_hours.sort_by{|x| (x[:department] ? x[:department].upcase : "") }
    when 3
      @less_hours = params[:sSortDir_0].upcase == "DESC" ? @less_hours.sort{|x,y| (y[:division] ? y[:division].upcase : "") <=> (x[:division] ? x[:division].upcase : "") } : @less_hours.sort_by{|x| (x[:division] ? x[:division].upcase : "") }
    when 4
      @less_hours = params[:sSortDir_0].upcase == "DESC" ? @less_hours.sort{|x,y| y[:date] <=> x[:date] } : @less_hours.sort_by{|x| x[:date] }
    when 7
      @less_hours = params[:sSortDir_0].upcase == "DESC" ? @less_hours.sort{|x,y| y[:work_length] <=> x[:work_length] } : @less_hours.sort_by{|x| x[:work_length] }
    else
    end
    @less_hours = @less_hours[ (@start_index) .. (@start_index + @display_length - 1) ]
    @iTotalRecords = @total_less_hours.count
    @iTotalDisplayRecords = @less_hours.count
    @sEcho = params[:sEcho].to_i
    render :partial => 'absences/table/less_hour_table'
  end

  def less_hour_popup
    @presence_ids = params[:presence_ids]
    if @presence_ids and Presence.is_presence_ids_belongs_to_current_company?(@presence_ids, current_company_id)
      @presence = Presence.more_less_worktime(@presence_ids[0].to_i)
      unless params["ignored"].blank?
        @popup = 2
        @title = "Dianggap Jam Kerja Kurang"
      else
        @popup = 1
        @title = "Dianggap Ijin"
      end
    end
    render :partial => 'absences/popup_pages/popup_less_hour'
  end

  def less_hour_action
    presence_ids = params[:presence_ids].to_a
    if presence_ids and Presence.is_presence_ids_belongs_to_current_company?(presence_ids, current_company_id)
      popup = params[:popup]
      reason = params[:reason]
      fulltime = params[:fulltime]
      @presence = Presence.more_less_worktime(presence_ids[0].to_i)
      if popup.to_i == 1
        same_all = params[:same_all]
        if same_all == "false"
          @less = Presence.find(presence_ids[0].to_i)
          @less.presence_description = reason
          @less.deem_as_absent(1)
        else
          @less = Presence.find(:all, :conditions => { :id => presence_ids})
          @less.each do |presence|
            presence.presence_description = reason
            presence.deem_as_absent(1)
          end
        end
        flash.now[:notice] = "Kekurangan jam kerja karyawan berhasil dianggap ijin"
      elsif popup.to_i == 2
        same_all = params[:same_all]
        if same_all == "false"
          @less = Presence.find(presence_ids[0].to_i)
          @less.presence_description = reason
          @less.set_is_acted_upon(4)
        else
          @less = Presence.find(:all, :conditions => { :id => presence_ids})
          @less.each do |presence|
            presence.presence_description = reason
            presence.set_is_acted_upon(4)
          end
        end
        flash.now[:notice] = "Karyawan berhasil dianggap jam kerja kurang"
      elsif fulltime
        @less = Presence.find(:all, :conditions => { :id => presence_ids})
        @less.each do |presence|
          schedule = presence.person.current_schedule(presence.presence_date)
          duration = schedule[:schedule_length]
          presence.presence_length_in_hours = duration
          presence.set_is_acted_upon(4)
        end
        flash.now[:notice] = "Karyawan berhasil dianggap dinas luar"
      else
        @less = Presence.find(:all, :conditions => { :id => presence_ids})
        @less.each do |presence|
          presence.deem_as_absent(2)
        end
        flash.now[:notice] = "Kekurangan jam kerja karyawan berhasil dicutikan"
      end
    end
    respond_to do |format|
      format.html { redirect_to :action => 'less_hour', :layout => false }
      format.js { render :text => flash.now[:notice] }
    end
  end

  # Break Time More ==============================================================
  def more_rest
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Istirahat Lebih", "#more_rest"
    render :layout => false
  end

  def more_rest_table
    @total_more_rests = Presence.breaktime_more_than_normal(current_company_id, @date_start, @date_end, @options)
    @more_rest_exist = Presence.all(:conditions => ["company_id = ?", current_company_id], :limit => 1).count
    set_data_to_session("more_rest")
    @more_rests = @total_more_rests
    case params[:iSortCol_0].to_i
    when 1
      @more_rests = params[:sSortDir_0].upcase == "DESC" ? @more_rests.sort{|x,y| y[:person_name].upcase <=> x[:person_name].upcase } : @more_rests.sort_by{|x| x[:person_name].upcase}
    when 2
      @more_rests = params[:sSortDir_0].upcase == "DESC" ? @more_rests.sort{|x,y| (y[:department] ? y[:department].upcase : "") <=> (x[:department] ? x[:department].upcase : "") } : @more_rests.sort_by{|x| (x[:department] ? x[:department].upcase : "") }
    when 3
      @more_rests = params[:sSortDir_0].upcase == "DESC" ? @more_rests.sort{|x,y| (y[:division] ? y[:division].upcase : "") <=> (x[:division] ? x[:division].upcase : "") } : @more_rests.sort_by{|x| (x[:division] ? x[:division].upcase : "") }
    when 4
      @more_rests = params[:sSortDir_0].upcase == "DESC" ? @more_rests.sort{|x,y| y[:date] <=> x[:date] } : @more_rests.sort_by{|x| x[:date] }
    when 5
      @more_rests = params[:sSortDir_0].upcase == "DESC" ? @more_rests.sort{|x,y| y[:break_length] <=> x[:break_length] } : @more_rests.sort_by{|x| x[:break_length] }
    else
    end
    @more_rests = @more_rests[ (@start_index) .. (@start_index + @display_length - 1) ]

    @iTotalRecords = @total_more_rests.count
    @iTotalDisplayRecords = @more_rests.count
    @sEcho = params[:sEcho].to_i
    render :partial => 'absences/table/more_rest_table'
  end

  def more_rest_popup
    presence_ids = params[:presence_ids]
    if presence_ids and Presence.is_presence_ids_belongs_to_current_company?(presence_ids, current_company_id)
      @presence = Presence.find(presence_ids[0].to_i)
    end
    render :partial => 'absences/popup_pages/popup_more_rest'
  end

  def more_rest_action
    presence_ids = params[:presence_ids].to_a
    if presence_ids and Presence.is_presence_ids_belongs_to_current_company?(presence_ids, current_company_id)
      reason = params[:reason]
      if params[:popup]
        same_all = params[:same_all]
        if same_all == "false"
          @presence = Presence.find(presence_ids[0].to_i)
          @presence.presence_description = reason
          @presence.set_is_acted_upon(8)
          @presence.save
        else
          presence_ids.each do |presence_id|
            @presence = Presence.find(presence_id.to_i)
            @presence.presence_description = reason
            @presence.set_is_acted_upon(8)
            @presence.save
          end
        end
        flash.now[:notice] = "Kelebihan istirahat karyawan berhasil diberi keterangan"
      else
        @presences = Presence.find(:all, :conditions => { :id => presence_ids})
        @presences.each do |presence|
          presence.normalize_breaktime(8)
        end
        flash.now[:notice] = "Kelebihan istirahat karyawan berhasil disesuaikan"
      end
    end
    respond_to do |format|
      format.html { redirect_to :action => 'more_rest', :layout => false }
      format.js { render :text => flash.now[:notice] }
    end
  end

  # Break Time Less ==============================================================
  def less_rest
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Istirahat Kurang", "#lest_rest"
    render :layout => false
  end

  def less_rest_table
    @total_less_rests = Presence.breaktime_less_than_normal(current_company_id, @date_start, @date_end, @options)
    @less_rest_exist = Presence.all(:conditions => ["company_id = ?", current_company_id], :limit => 1).count
    set_data_to_session("less_rest")
    @less_rests = @total_less_rests
    case params[:iSortCol_0].to_i
    when 1
      @less_rests = params[:sSortDir_0].upcase == "DESC" ? @less_rests.sort{|x,y| y[:person_name].upcase <=> x[:person_name].upcase } : @less_rests.sort_by{|x| x[:person_name].upcase}
    when 2
      @less_rests = params[:sSortDir_0].upcase == "DESC" ? @less_rests.sort{|x,y| (y[:department] ? y[:department].upcase : "") <=> (x[:department] ? x[:department].upcase : "") } : @less_rests.sort_by{|x| (x[:department] ? x[:department].upcase : "") }
    when 3
      @less_rests = params[:sSortDir_0].upcase == "DESC" ? @less_rests.sort{|x,y| (y[:division] ? y[:division].upcase : "") <=> (x[:division] ? x[:division].upcase : "") } : @less_rests.sort_by{|x| (x[:division] ? x[:division].upcase : "") }
    when 4
      @less_rests = params[:sSortDir_0].upcase == "DESC" ? @less_rests.sort{|x,y| y[:date] <=> x[:date] } : @less_rests.sort_by{|x| x[:date] }
    when 5
      @less_rests = params[:sSortDir_0].upcase == "DESC" ? @less_rests.sort{|x,y| y[:break_length] <=> x[:break_length] } : @less_rests.sort_by{|x| x[:break_length] }
    else
    end
    @less_rests = @less_rests[ (@start_index) .. (@start_index + @display_length - 1) ]

    @iTotalRecords = @total_less_rests.count
    @iTotalDisplayRecords = @less_rests.count
    @sEcho = params[:sEcho].to_i
    render :partial => 'absences/table/less_rest_table'
  end

  def less_rest_action
    presence_ids = params[:presence_ids]
    if presence_ids and Presence.is_presence_ids_belongs_to_current_company?(presence_ids, current_company_id)
      @presences = Presence.find(:all, :conditions => { :id => presence_ids})
      @presences.each do |presence|
        presence.normalize_breaktime(16)
      end
      flash.now[:notice] = "Kekurangan istirahat karyawan berhasil disesuaikan"
    end
    respond_to do |format|
      format.html { redirect_to :action => 'less_rest', :layout => false }
      format.js { render :text => flash.now[:notice] }
    end
  end

  # Absent =======================================================================
  def absent
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Tidak Masuk", "#absent"
    @absence_types = AbsenceType.all(:conditions => ['company_id = ?', current_company_id])
    render :layout => false
  end

  def absent_table
    @total_absents = Presence.who_is_not_working(current_company_id, @date_start, @date_end, @options)
    @absent_exist = Presence.all(:conditions => ["company_id = ?", current_company_id], :limit => 1).count
    @absent_exist += Absence.all(:conditions => ["company_id = ?", current_company_id], :limit => 1).count
    @absent_exist += EmployeeShift.all(:conditions => ["company_id = ?", current_company_id], :limit => 1).count
    set_data_to_session
    @absents = @total_absents
    case params[:iSortCol_0].to_i
    when 1
      @absents = params[:sSortDir_0].upcase == "DESC" ? @absents.sort{|x,y| y[:person].full_name <=> x[:person].full_name } : @absents.sort_by{|x| x[:person].full_name}
    when 2
      @absents = params[:sSortDir_0].upcase == "DESC" ? @absents.sort{|x,y| (y[:department] ? y[:department].department_name.upcase : "") <=> (x[:department] ? x[:department].department_name.upcase : "") } : @absents.sort_by{|x| (x[:department] ? x[:department].department_name.upcase : "") }
    when 3
      @absents = params[:sSortDir_0].upcase == "DESC" ? @absents.sort{|x,y| (y[:division] ? y[:division].name.upcase : "") <=> (x[:division] ? x[:division].name.upcase : "") } : @absents.sort_by{|x| (x[:division] ? x[:division].name.upcase : "") }
    when 4
      @absents = params[:sSortDir_0].upcase == "DESC" ? @absents.sort{|x,y| y[:date] <=> x[:date] } : @absents.sort_by{|x| x[:date] }
    when 5
      @absents = params[:sSortDir_0].upcase == "DESC" ? @absents.sort{|x,y| (y[:type] ? y[:type] : "") <=> (x[:type] ? x[:type] : "") } : @absents.sort_by{|x| (x[:type] ? x[:type] : "") }
    else
    end
    @absents = @absents[ (@start_index) .. (@start_index + @display_length - 1) ]

    @iTotalRecords = @total_absents.count
    @iTotalDisplayRecords = @absents.count
    @sEcho = params[:sEcho].to_i
    render :partial => 'absences/table/absent_table'
  end

  def absent_popup
    person_ids = params[:person_ids]
    if person_ids and Person.is_person_ids_belongs_to_current_company?(person_ids, current_company_id)
      absent_dates = params[:absent_date]
      @absent_type = params[:absent_type].to_i
      @person = Person.find_by_id(person_ids[0].to_i)
      @absent_date = Date.parse(absent_dates[0])
    end
    render :partial => 'absences/popup_pages/popup_absent'
  end

  def absent_action
    person_ids = params[:person_ids].to_a
    absent_dates = params[:absent_date].to_a
    @absent_type = params[:absent_type].to_i
    @absent_type_id = AbsenceType.find(:first, :conditions => ['company_id = ? AND type_id = ?', current_company_id, @absent_type])
    same_all = params[:same_all]
    if same_all == "true"
      if @absent_type == 0
        person_ids.each_with_index do |person_id, index|
          @person = Person.find_by_id(person_id.to_i)
          @absent_date = Date.parse(absent_dates[index])
          present = @person.deem_as_working(@absent_date, params[:description], params[:work_length].to_f)
        end
        flash.now[:notice] = "Karyawan berhasil dianggap bekerja"
      elsif @absent_type == 5
        person_ids.each_with_index do |person_id, index|
          @person = Person.find_by_id(person_id.to_i)
          @absent_date = Date.parse(absent_dates[index])
          absent = @person.absences.new
          absent.make_absent(@absent_type_id.id,@absent_date,params[:description])
        end
        flash.now[:notice] = "Karyawan berhasil dianggap cuti khusus"
      end
      respond_to do |format|
        format.html { redirect_to :action => 'absent', :layout => false }
        format.js { render :text => flash.now[:notice] }
      end
    else
      if @absent_type == 0
        @person = Person.find_by_id(person_ids[0].to_i)
        @absent_date = Date.parse(absent_dates[0])
        present = @person.deem_as_working(@absent_date, params[:description], params[:work_length].to_f)
        if present
          flash.now[:notice] = "Karyawan berhasil dianggap bekerja"
        else
          flash.now[:notice] = "Ada kesalahan dalam input data"
        end
      elsif @absent_type == 5
        @person = Person.find_by_id(person_ids[0].to_i)
        @absent_date = Date.parse(absent_dates[0])
        absent = @person.absences.new
        absent.make_absent(@absent_type_id.id,@absent_date,params[:description])
        flash.now[:notice] = "Karyawan berhasil dianggap cuti khusus"
      else
        person_ids.each_with_index do |person_id,index|
          @person = Person.find_by_id(person_id)
          @absent_date = Date.parse(absent_dates[index])
          absent = @person.absences.new
          absent.make_absent(@absent_type_id.id,@absent_date)
        end
        flash.now[:notice] = "Karyawan berhasil dianggap #{@absent_type_id.absence_type_name}"
      end
      respond_to do |format|
        format.html { redirect_to :action => 'absent', :layout => false }
        format.js { render :text => flash.now[:notice] }
      end
    end
  end

  def new_absent
    render :layout => "application2"
  end
  # Absent =======================================================================
  def no_logout
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Absent Tidak Lengkap", "#absences/no_logout"
    render :layout => false
  end

  def no_logout_table
    @total_no_logouts = Presence.who_is_not_logout(current_company_id, @date_start, @date_end, @options)
    @no_logout_exist = Presence.all(:joins => :presence_details, :conditions => ["presences.company_id = ? AND (presence_details.start_working IS NULL OR presence_details.end_working IS NULL)", current_company_id], :limit => 1).count
    set_data_to_session("absences/no_logout")
    @no_logouts = @total_no_logouts
    case params[:iSortCol_0].to_i
    when 1
      @no_logouts = params[:sSortDir_0].upcase == "DESC" ? @no_logouts.sort{|x,y| y[:person_name].to_s.upcase <=> x[:person_name].to_s.upcase } : @no_logouts.sort_by{|x| x[:person_name].to_s.upcase}
    when 2
      @no_logouts = params[:sSortDir_0].upcase == "DESC" ? @no_logouts.sort{|x,y| y[:department].to_s.upcase <=> x[:department].to_s.upcase } : @no_logouts.sort_by{|x| x[:department].to_s.upcase }
    when 3
      @no_logouts = params[:sSortDir_0].upcase == "DESC" ? @no_logouts.sort{|x,y| y[:division].to_s.upcase <=> x[:division].to_s.upcase } : @no_logouts.sort_by{|x| x[:division].to_s.upcase }
    when 4
      @no_logouts = params[:sSortDir_0].upcase == "DESC" ? @no_logouts.sort{|x,y| y[:position].to_s.upcase <=> x[:position].to_s.upcase } : @no_logouts.sort_by{|x| x[:division].to_s.upcase }
    when 5
      @no_logouts = params[:sSortDir_0].upcase == "DESC" ? @no_logouts.sort{|x,y| y[:date] <=> x[:date] } : @no_logouts.sort_by{|x| x[:date] }
    else
    end
    @no_logouts = @no_logouts[ (@start_index) .. (@start_index + @display_length - 1) ]

    @iTotalRecords = @total_no_logouts.count
    @iTotalDisplayRecords = @no_logouts.count
    @sEcho = params[:sEcho].to_i
    render :partial => 'absences/table/no_logout_table'
  end

  def no_logout_popup
    presence_ids = params[:presence_ids]
    @presence_detail = PresenceDetail.find(presence_ids[0].to_i)
    if presence_ids and Presence.is_presence_ids_belongs_to_current_company?(@presence_detail.presence_id, current_company_id)
      @presence = @presence_detail.presence
    end
    render :partial => 'absences/popup_pages/popup_no_logout'
  end

  def no_logout_action
    presence_ids = params[:presence_ids].to_a
    @presence_detail = PresenceDetail.find(presence_ids[0].to_i)
    if presence_ids and Presence.is_presence_ids_belongs_to_current_company?(@presence_detail.presence_id, current_company_id)
      same_all = params[:same_all]
      end_working = Time.parse(params[:end_work])
      if same_all == "false"
        @presence_detail = PresenceDetail.find(presence_ids[0].to_i)
        @presence = @presence_detail.presence
        if @presence_detail.end_working.blank?
          @presence_detail.end_working = end_working
          @presence_detail.calculate_time
          @presence.set_is_acted_upon(64)
          @presence.calculate_work_time
          sched_time = @presence.person.current_schedule(@presence.presence_date)
          unless sched_time.blank?
            @presence.calculate_overtime
          end
          flash.now[:notice] = "Absen keluar karyawan berhasil!"
          respond_to do |format|
            format.js {  render :text => flash.now[:notice] }
          end
        else
          @presence_detail.start_working = end_working
          @presence_detail.calculate_time
          @presence.set_is_acted_upon(128)
          @presence.calculate_work_time
          sched_time = @presence.person.current_schedule(@presence.presence_date)
          unless sched_time.blank?
            @presence.calculate_overtime
          end
          flash.now[:notice] = "Absen masuk karyawan berhasil!"
          respond_to do |format|
            format.js {  render :text => flash.now[:notice] }
          end
        end
      else
        presence_ids.each do |presence_id|
          @presence_detail = PresenceDetail.find(presence_id)
          @presence = @presence_detail.presence
          if @presence_detail.end_working.blank?
            @presence_detail.end_working = end_working
            @presence_detail.calculate_time
            @presence.set_is_acted_upon(64)
            @presence.calculate_work_time
            sched_time = @presence.person.current_schedule(@presence.presence_date)
            unless sched_time.blank?
              @presence.calculate_overtime
            end
            flash.now[:notice] = "Absen keluar karyawan berhasil!"
            respond_to do |format|
              format.js {  render :text => flash.now[:notice] }
            end
          else
            @presence_detail.start_working = end_working
            @presence_detail.calculate_time
            @presence.set_is_acted_upon(128)
            @presence.calculate_work_time
            sched_time = @presence.person.current_schedule(@presence.presence_date)
            unless sched_time.blank?
              @presence.calculate_overtime
            end
            flash.now[:notice] = "Absen masuk karyawan berhasil!"
            respond_to do |format|
              format.js {  render :text => flash.now[:notice] }
            end
          end
        end
      end
    end
  end

  # My Absence ===================================================================
  def my_absence
    prepare_myabsence2
    render :layout => false
  end

  def remove_presence
    presence = Presence.find(params[:presence_id])
    if presence and presence.company_id == current_company_id
      the_presence = PresenceDetail.find(presence.id)
      if !the_presence.nil? && (the_presence.presence.is_acted_upon.blank? || the_presence.presence.is_acted_upon == 0)
        presence = Presence.find(the_presence.presence_id)
        presence.balance_time(the_presence.work_session_length_in_minutes) unless the_presence.work_session_length_in_minutes.blank?
        the_presence.destroy
        prepare_myabsence2
        #reload_page('div_presence_detail', 'list_myabsences2')
        render :update do |page|
          page.replace_html 'div_presence_detail', :partial=> 'list_myabsences2'
          page << "$('.notify_error').show();$('.message').html('Data absensi berhasil dihapus')"
          page << "parent.$.fn.colorbox.close();"
        end
      else
        render :nothing => true, :status => 201
      end
    else
      render :nothing => true, :status => 201
    end
  end

  def my_monthly_absence
    add_breadcrumb "Karyawan", "#person_index"
    add_breadcrumb "Daftar karyawan", "#person_index"
    add_breadcrumb "Data Absensi", "#absences/mine?id=#{@current_person.id}&profiles=1"
    add_breadcrumb "Absensi bulanan #{@current_person.full_name}", "#monthlyabsence/#{@current_person.id}?date_start_month=#{@date_month}&date_start_year=#{@date_year}"
    render :layout => false
  end

  def my_monthly_absence_table
    session[:conditions] = "person_id = #{@current_person.id} AND date BETWEEN '#{@date_start.to_s(:db)}' AND '#{@date_end.to_s(:db)}' AND company_id = #{current_company_id}"
    @presences_from_report = PresenceReport.find_by_custom_conditions(current_conditions)

    @absence_type = AbsenceType.all(:conditions => ['company_id = ?', current_company_id])
    @display_length = params[:iDisplayLength].to_i
    @iTotalRecords = (@date_start..@date_end).count
    @iTotalDisplayRecords = (@date_start..@date_end).count
    @sEcho = params[:sEcho].to_i

    render :partial => 'absences/table/my_monthly_table'
  end

  def my_yearly_absence
    if params[:year]
      @year = Date.civil(params[:year].to_i)
    else
      @year = Date.today
    end
    unless @current_person.blank?
      @person = @current_person
      if @current_person.presences
        @total_presence = @current_person.presences.total_work_days_yearly(@year.year)
      end
      if @current_person.absences
        @total_excuse = @current_person.absences.sequential_absences(current_company_id, 1, @year.at_beginning_of_year, @year.at_end_of_year)
        @total_leave = @current_person.absences.sequential_absences(current_company_id, 2, @year.at_beginning_of_year, @year.at_end_of_year)
        @total_awol = @current_person.absences.sequential_absences(current_company_id, 4, @year.at_beginning_of_year, @year.at_end_of_year)
        @total_sick_leave = @current_person.absences.sequential_absences(current_company_id, 3, @year.at_beginning_of_year, @year.at_end_of_year)
        @total_special_leave = @current_person.absences.sequential_absences(current_company_id, 5, @year.at_beginning_of_year, @year.at_end_of_year)
        @total_birth_leave = @current_person.absences.sequential_absences(current_company_id, 6, @year.at_beginning_of_year, @year.at_end_of_year)
        @total_accident_leave = @current_person.absences.sequential_absences(current_company_id, 7, @year.at_beginning_of_year, @year.at_end_of_year)

        @sum_total_excuse = @current_person.absences.total_by_type(1, @year.at_beginning_of_year, @year.at_end_of_year, current_company_id)
        @sum_total_leave = @current_person.absences.total_by_type(2, @year.at_beginning_of_year, @year.at_end_of_year, current_company_id)
        @sum_total_awol = @current_person.absences.total_by_type(4, @year.at_beginning_of_year, @year.at_end_of_year, current_company_id)
        @sum_total_sick_leave = @current_person.absences.total_by_type(3, @year.at_beginning_of_year, @year.at_end_of_year, current_company_id)
        @sum_total_special_leave = @current_person.absences.total_by_type(5, @year.at_beginning_of_year, @year.at_end_of_year, current_company_id)
        @sum_total_birth_leave = @current_person.absences.total_by_type(6, @year.at_beginning_of_year, @year.at_end_of_year, current_company_id)
        @sum_total_accident_leave = @current_person.absences.total_by_type(7, @year.at_beginning_of_year, @year.at_end_of_year, current_company_id)
      end
    end
    render :layout => false
  end

  # Absences per Person (Tab on Person Profiles)==================================
  def mine
    @profile = false
    @person = @current_person
    unless @current_person.blank?
      add_breadcrumb "Karyawan", "#person_index"
      add_breadcrumb "Daftar karyawan", "#person_index"
      add_breadcrumb "Data Absensi", "#absences/mine?id=#{@person.id}&profiles=#{params[:profiles]}"
      @this_year_quota = @person.leave_quota
      @join_leaves = @this_year_quota.blank? ? 0 : NationalHoliday.join_leaves_count(@person.company_id, @this_year_quota.start_date, @this_year_quota.end_date)
      @leaves_count = @this_year_quota.blank? ? 0 : @person.employee_leaves.approved_leaves_count(@this_year_quota.start_date, @this_year_quota.end_date)
      @current_remaining_quota = @person.current_leave_quota_days
      unless @this_year_quota.blank?
        @last_year_quota = @person.leaves_quotas.my_quota(@this_year_quota.start_date.to_date - 1)
        if @last_year_quota
          @last_remaining_quota = @person.leaves_quotas.remaining_quota(@last_year_quota.end_date)
        end
      end
      if @current_person.presences
        @total_presence = @current_person.presences.total_work_days(@date_start.month, @date_start.year)
      end
      if @current_person.absences
        @sum_total_excuse = @current_person.absences.total_by_type(1, @date_start, @date_end, current_company_id)
        @sum_total_leave = @current_person.absences.total_by_type(2, @date_start, @date_end, current_company_id)
        @sum_total_awol = @current_person.absences.total_by_type(4, @date_start, @date_end, current_company_id)
        @sum_total_sick_leave = @current_person.absences.total_by_type(3, @date_start, @date_end, current_company_id)
        @sum_total_special_leave = @current_person.absences.total_by_type(5, @date_start, @date_end, current_company_id)
        @sum_total_birth_leave = @current_person.absences.total_by_type(6, @date_start, @date_end, current_company_id)
        @sum_total_accident_leave = @current_person.absences.total_by_type(7, @date_start, @date_end, current_company_id)
      end
      if @person.user_id != current_user.id || params[:profiles]
        @profile = true
        render :layout => false
      end
    else
      render :layout => false
    end
  end

  def redeem_leaves
    @current_year_quota = LeavesQuota.find(params[:current_quota])
    action = params[:quota_action].to_i
    @redeemed_days = params[:redeemed_days].to_i

    if action == 1
      @current_year_quota.transfer_quota(true)
    elsif action == 2
      @current_year_quota.transfer_quota
    end
    render :nothing => :true, :status => 200
  end

  # Rekap Absen Karyawan ============================================================

  def presence_report
    @total_reports = PresenceReport.summary_report(@date_start, @date_end, current_company_id)
    @reports = @total_reports

    @iTotalRecords = @total_reports.count
    @iTotalDisplayRecords = @reports.count
    respond_to do |format|
      format.html { render :layout => false}
    end
  end

  def list_presence_report
    render :partial=> 'absences/list_presence_report'
  end

  def presence_report_table
    @options = {}
    name = params[:name] if params[:name] != "undefined"
    unless name.blank?
      @options[:name] = name
      @options[:condition] = "(firstname LIKE '%#{name}%' OR lastname LIKE '%#{name}%' OR CONCAT(TRIM(firstname),' ',TRIM(lastname)) LIKE '%#{name}%')"
    end
    @total_reports_count = PresenceReport.count_total_by_date_range(@date_start, @date_end, current_company_id, @options)
    @display_length = params[:iDisplayLength].to_i
    @name = params[:name] if params[:name] != "undefined"
    @start_index = params[:iDisplayStart].to_i
    @options[:start_index] = @start_index
    @options[:display_length] = @display_length
    @options[:name] = @name
    @reports = PresenceReport.summary_report(@date_start, @date_end, current_company_id, @options)
    session[:conditions] = @options
    @iTotalRecords = @total_reports_count
    @iTotalDisplayRecords = @reports.count
    render :update do |page|
      page.replace_html 'presence_report_page', :partial => 'absences/list_presence_report'
    end
  end

  def absence_report_table
    @options = {}
    name = params[:name] if params[:name] != "undefined"
    unless name.blank?
      @options[:name] = name
      @options[:condition] = "(firstname LIKE '%#{name}%' OR lastname LIKE '%#{name}%' OR CONCAT(TRIM(firstname),' ',TRIM(lastname)) LIKE '%#{name}%')"
    end
    @name = params[:name] if params[:name] != "undefined"
    @display_length = params[:iDisplayLength].to_i
    @start_index = params[:iDisplayStart].to_i
    @options[:start_index] = @start_index
    @options[:display_length] = @display_length
    @options[:name] = @name
    session[:conditions] = @options

    conditions = "(firstname LIKE '%#{name}%' OR lastname LIKE '%#{name}%' OR CONCAT(TRIM(firstname),' ',TRIM(lastname)) LIKE '%#{name}%') AND people.company_id=#{current_company_id}"
    people = Person.find_from_params(conditions, @options)

    @reports = PresenceReport.summary_absence_report(@date_start, @date_end, conditions, people, @options)

    @iTotalRecords = Person.all(:conditions => conditions, :include=> [:employments]).count
    @iTotalDisplayRecords = @reports.count

    render :update do |page|
      page.replace_html 'absence_report_page', :partial => 'absences/list_absence_report'
    end
  end

  def export_presence_report_xls
    kond = current_conditions
    kond.delete(:display_length)
    @reports = PresenceReport.summary_report(@date_start, @date_end, current_company_id, kond)
    @reports = @reports.sort_by{|rep| rep[:department].to_s}

    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "#{@date_start.strftime("%Y%m%d")}-#{@date_end.strftime("%Y%m%d")}"
    format = Spreadsheet::Format.new :weight => :bold, :horizontal_align => :centre, :border => 1
    border_format = Spreadsheet::Format.new :border => 1
    date_array = []
    (@date_start..@date_end).each do |date|
      date_array << date.strftime("%d")
      if date.wday == 0 || date == @date_end
        date_array << "Lembur #{date.strftime("%d")}"
      end
    end
    row_length = date_array.length + 11
    row_length.times {|i| data_sheet.row(3).set_format(i, format)}
    data_sheet.row(0).replace ["Rekap Absensi"]
    data_sheet.row(1).replace ["Tanggal #{l @date_start} s.d. #{l @date_end}"]
    data_sheet.row(3).replace [ 'No', 'Departemen', 'Bagian', 'NIK', 'Nama Lengkap'] + date_array +['L1(Jam)', 'L2(Jam)', 'L3(Jam)', 'L4(Jam)', 'Total Lembur', 'Keterangan']

    @reports.each_with_index do |report, index|
      row_length.times {|i| data_sheet.row(index+4).set_format(i, border_format)}
      work_summary = []
      report[:work_time].each_with_index do |work_time, rec|
        work_summary << [work_time, "(#{report[:shift_code][rec]})"].join(" ")
        if report[:date][rec].wday == 0 || report[:date][rec] == @date_end
          work_summary << report[:weekly_overtime][rec]
        end
      end
      data_sheet.row(index+4).replace ["#{index+1}.", report[:department].to_s,
        report[:division].to_s, report[:employee_id], report[:name].titleize]+
        work_summary+
        [report[:overtime1], report[:overtime2], report[:overtime3], report[:overtime4],
        report[:overtime_total]
      ]
    end
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :disposition=>'attachment', :filename => "Absensi_#{@date_start.strftime("%Y%m%d")}_#{@date_end.strftime("%Y%m%d")}.xls", :type =>  :xls
  end

  # Export tab Absensi dan Lembur ============================================================
  def export_my_absence
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "absensi harian #{@current_person.full_name}"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Jam Masuk','Jam Keluar','Lama Kerja']
    data_sheet = set_data_export_my_absence(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "absent_harian_#{@current_person.full_name}.xls", :type =>  "application/vnd.ms-excel"
  end

  def export_my_yearly_absence
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Absent Tahunan #{@current_person.full_name}"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Bulan','Hari Kerja','Lama Kerja','Terlambat','Ijin','Cuti','Sakit','Cuti Khusus','Cuti Melahirkan','Mangkir','Cuti Kecelakaan','Keterangan']
    data_sheet = set_data_export_my_yearly_absence(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "absent_tahunan_#{@current_person.full_name}.xls", :type =>  "application/vnd.ms-excel"
  end

  def export_my_monthly_absence
    presences_from_report = PresenceReport.find_by_custom_conditions(current_conditions)
    person = Person.find(presences_from_report.first.person_id);
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Absent Bulanan #{person.full_name}"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Hari','Tanggal','Jam Masuk','Jam Keluar','Lama kerja','Lembur','Keterangan']
    data_sheet = set_data_export_my_monthly_absence(data_sheet, presences_from_report)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "absent_bulanan_#{person.full_name}.xls", :type =>  "application/vnd.ms-excel"
  end

  def export_no_logout
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Absent Tidak Lengkap"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Nama','Department','Bagian','Jabatan','Tanggal','Jam Masuk','Jam Keluar','Keterangan']
    data_sheet = set_data_export_no_logout_table(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "absent_tidak_lengkap.xls", :type =>  "application/vnd.ms-excel"
  end

  def export_absent
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Tidak Masuk"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Nama','Department','Bagian','Tanggal','Tipe','Sisa Jatah Cuti','Jumlah izin','Keterangan']
    data_sheet = set_data_export_absent_table(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "tidak_masuk.xls", :type =>  "application/vnd.ms-excel"
  end

  def export_less_rest
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Istirahat Kurang"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Nama','Department','Bagian','Tanggal','Lama Istirahat','Status','Keterangan']
    data_sheet = set_data_export_less_rest_table(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "istirahat_kurang.xls", :type =>  "application/vnd.ms-excel"
  end

  def export_more_rest
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Istirahat Lebih"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Nama','Department','Bagian','Tanggal','Lama Istirahat','Status','Keterangan']
    data_sheet = set_data_export_more_rest_table(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "istirahat_lebih.xls", :type =>  "application/vnd.ms-excel"
  end

  def export_less_hour
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Kerja kurang"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Nama','Department','Bagian','Tanggal','Jam Mulai','Jam Selesai','Lama Kerja','Alasan/Status']
    data_sheet = set_data_export_less_hour_table(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "kerja_kurang.xls", :type =>  "application/vnd.ms-excel"
  end

  def export_more_hour
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Kerja Lebih"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Nama','Department','Bagian','Tanggal','Jam Mulai','Jam Selesai','Lama Kerja','Status']
    data_sheet = set_data_export_more_hour_table(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "kerja_lebih.xls", :type =>  "application/vnd.ms-excel"
  end

  def export_late
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Terlambat Kerja"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    data_sheet.row(0).replace ['Nama','Department','Bagian','Shift','Tanggal','Masuk Kerja','Terlambat','Keterangan','Status']
    data_sheet = set_data_export_late_table(data_sheet)
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "terlambat_kerja.xls", :type =>  "application/vnd.ms-excel"
  end

  def export_absensi_kerja
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "Absensi Kerja"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format
    if session[:url_act] == "monthly_index_table"
      data_sheet.row(0).replace ['Nama Karyawan','Department','Bagian','Kehadiran','Cuti / Ijin','Sakit','Mangkir']
      data_sheet = set_data_export_monthly_index_table(data_sheet)
    elsif session[:url_act] == "absences"
      data_sheet.row(0).replace ['Nama Karyawan','Department','Bagian','Jam Mulai','Jam Selesai','Istirahat','Lama Kerja']
      data_sheet = set_data_export_daily_index_table(data_sheet)
    end
    spreadsheet = StringIO.new
    workbook.write spreadsheet
    time = session[:url_act] == "monthly_index_table"? "Bulanan" : "Harian"
    send_data spreadsheet.string, :filename => "absensi_kerja_#{time}.xls", :type =>  "application/vnd.ms-excel"
  end

  def popup_absent_to_people
    render :layout => false
  end
  
  def popup_import_data_absent
    @import = Import.new
    render :layout => false
  end
  
  # Absenkan Karyawan ============================================================
  def employee_present
    set_error_field_blank
    unless @str_error.blank?
      unsuccess_absent_present
    else
      set_time
      person = Person.get_person_name_by_department_and_division(params["person-name"], current_company_id)
      @absent_type = params["absen"].to_i
      if @absent_type == 0
        person_present(person)
      else
        person_absent(person)
      end
    end
  end

  # Start/End Work ===============================================================
  def start_work
    today = Date.today.strftime("%Y-%m-%d")
    Presence.login(@current_person)
    respond_to do |format|
      format.html { redirect_to("#{current_root_url}#dailyabsence?id=#{@current_person.id}&date=#{today}") }
      format.js { render :nothing => true }
    end
  end

  def end_work
    today = Date.today.strftime("%Y-%m-%d")
    Presence.logout_manual(@current_person)
    respond_to do |format|
      format.html { redirect_to("#{current_root_url}#dailyabsence?id=#{@current_person.id}&date=#{today}") }
      format.js { render :nothing => true }
    end
  end

  def divisions_by_department
    @divisions = params[:id].present?? Department.find(params[:id]).divisions.all(:order => "name") :
      Division.all(:conditions => {:company_id => current_company_id}, :order => "name")
    respond_to do |format|
      format.js
    end
  end

  # Download Dari Alat Tab =====================================================================
  def download_from_device
    add_breadcrumb "Waktu Kerja dan Lembur", "#absences"
    add_breadcrumb "Download Data Kehadiran Dari Alat Fingerprint", "#download_from_Device"
    @fingerprint_device = FingerprintDevice.find_all_by_company_id(current_company_id)
    @download_process = DownloadDataLog.last(:conditions => {:company_id => current_company_id, :end_time => nil})
    render :layout => false
  end

  def download_data
    DownloadDataLog.create(:company_id => current_company_id, :end_time => nil)
    MiddleMan.worker(:app_worker).async_download_attendance(:args => {:company_id => current_company_id}, :job_key => "Download_Data_CompanyID_#{current_company_id}")
    render :nothing => true
  end

  private

  def person_present(person)
    if @date && person
      if person.employment(@date)
        present_date(person)
      else
        unsuccess_absent_present(2)
      end
    else
      unsuccess_absent_present(1)
    end
  end

  def person_absent(person)
    absence_type = params[:employee][:absence_type].to_i
    if @date && person
      if person.current_employment
        absence = person.absences.new
        reason = params[:reason] if params[:reason] != "undefined"
        absence.make_absent(absence_type, @date, reason)
        success_absent_present
      else
        unsuccess_absent_present(2)
      end
    else
      unsuccess_absent_present(1)
    end
  end

  def present_date(person)
    presence = person.presences.find_by_presence_date(@date)
    absence = person.absences.find_by_absence_date(@date)
    unless presence || absence
      presence = Presence.login(person,@start_time)
      unless @end_time.blank? || @date == Date.today
        presence = Presence.logout(person,@end_time,@rest_time)
      end
      if presence
        presence.set_is_acted_upon(256)
        success_absent_present
      else
        unsuccess_absent_present
      end
    else
      if presence
        success_absent_present(1)
      else
        success_absent_present(2, absence)
      end
    end
  end

  def set_error_field_blank
    @str_error = {}
    @abset_type = params[:absen].to_i
    if params["person-name"].blank?
      @str_error["person-name"] = "Nama tidak boleh kosong"
    end
    if @abset_type == 1
      if params[:employee][:absence_type].blank?
        @str_error["alasan"] = "Alasan tidak boleh kosong"
      end
    end
  end

  def set_time
    @date = Date.strptime(params[:present_temp_date], '%d/%m/%Y') if params[:present_temp_date]

    start_date = Person.format_date(params[:present_temp_date])+" "+ params[:start_working][:hour]+":"+params[:start_working][:minute]
    @start_time = Time.parse(start_date)

    end_date = Person.format_date(params[:present_temp_date])+" "+ params[:end_working][:hour]+":"+params[:end_working][:minute]
    @end_time = Time.parse(end_date)

    @rest_time = params[:rest_time].to_i
    return_page = [current_root_url,params[:return_page]].join("#")

    if @end_time && @end_time < @start_time
      @end_time = @end_time.tomorrow
    end
  end

  def success_absent_present(msg = 0, absence = nil)
    url = ""
    if @absent_type == 0
      url = "#absences?save=create_present&msg=#{msg}"
      url << "&absen=#{absence.absence_type.absence_type_name}" unless absence.blank?
    else
      url = "#absent?save=create_absent"
      url << "&absen=#{absence.absence_type.absence_type_name}" unless absence.blank?
    end
    render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#{url}';parent.location.reload();</script></body></html>"
  end

  def unsuccess_absent_present(msg = 0)
    message = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
    if msg == 1
      @str_error["person-name"] = "Karyawan tidak berhasil diabsenkan!"
    elsif msg == 2
      @str_error["person-name"] = "Karyawan tidak terdaftar!"
    end
    flash.now[:notice] = message
    render :layout=> false, :action => :popup_absent_to_people
  end

  def set_data_export_my_yearly_absence(data_sheet)
    (1..12).each do |month|
      date = Presence.get_year(params, month)
      date_start = date[:date_start]
      total_presence = @current_person.presences.total_work_days(month, date[:year].year)
      total_ijin =  @current_person.absences.total_by_type(1, date_start, date_start.at_end_of_month, current_company_id)
      total_cuti =  @current_person.absences.total_by_type(2, date_start, date_start.at_end_of_month, current_company_id)
      total_sakit = @current_person.absences.total_by_type(3, date_start, date_start.at_end_of_month, current_company_id)
      total_cuti_khusus = @current_person.absences.total_by_type(5, date_start, date_start.at_end_of_month, current_company_id)
      sakit_melahirkan = @current_person.absences.total_by_type(6, date_start, date_start.at_end_of_month, current_company_id)
      mangkir = @current_person.absences.total_by_type(4, date_start, date_start.at_end_of_month, current_company_id)
      sakit_kecelakaan = @current_person.absences.total_by_type(7, date_start, date_start.at_end_of_month, current_company_id)
      data_sheet.row(month).replace [
        "#{l date_start, :format => "%B"}",
        "#{total_presence[:days]} Hari",
        "#{Presence.hours_to_hour_text(total_presence[:hours])}",
        "#{@current_person.presences.late_comers(@current_person.company_id, date_start, date_start.at_end_of_month).count} Kali",
        "#{total_ijin}",
        "#{total_cuti}",
        "#{total_sakit}",
        "#{total_cuti_khusus}",
        "#{sakit_melahirkan}",
        "#{mangkir}",
        "#{sakit_kecelakaan}",
        ""
      ]
    end
  end

  def set_data_export_my_monthly_absence(data_sheet, presences_from_report)
    presences_from_report.each_with_index do |row, index|
      item = Presence.get_item_for_monthly_absence(row, current_company_id)
      data_sheet.row(index+1).replace [
        "#{l row.date, :format => '%A'}",
        "#{l row.date}",
        item[:masuk], item[:keluar],item[:lama_kerja], item[:lembur], item[:keterangan]
      ]
    end
    summary = presences_from_report.count + 1
    data_sheet.row(summary).replace [
      "","TOTAL BULANAN :",
      Presence.hoursnum_to_hour(presences_from_report.sum{|p| p.work_duration.to_f}),
      Presence.minutes_to_hour(presences_from_report.sum{|p| p.overtime_duration.to_f}),
      ""
    ]
  end

  def set_data_export_my_absence(data_sheet)
    my_presence = @current_person.presences.find(:all, :conditions => current_conditions)
    no = 0
    my_presence.each_with_index do |presence, index|
      my_presence_details = presence.presence_details(:order => :start_working)
      my_presence_details.each do |presence_detail|
        time_start =  presence_detail.start_working.nil? ? "-" : "#{l presence_detail.start_working, :format => '%A'}, #{presence_detail.start_working.getlocal.strftime("%d/%m/%Y")}@ #{presence_detail.start_working.getlocal.strftime("%H:%M")}"
        if presence_detail.end_working
          time_end =  presence_detail.end_working.nil? ? "-" : "#{l presence_detail.end_working, :format => '%A'}, #{presence_detail.end_working.getlocal.strftime("%d/%m/%Y")}@ #{presence_detail.end_working.getlocal.strftime("%H:%M")}"
        end
        data_sheet.row(no+=1).replace [
          time_start,
          time_end,
          Presence.minutes_to_hour_text(presence_detail.work_session_length_in_minutes.to_i)
        ]
      end
      if !my_presence_details.first.nil? && my_presence_details.first.end_working
        data_sheet.row(no+=1).replace [
          "",
          "Total",
          Presence.hours_to_hour_text(presence.presence_length_in_hours.to_f)
        ]
      end
    end
  end


  def set_data_export_no_logout_table(data_sheet)
    get_data_from_session
    @total_no_logouts = Presence.who_is_not_logout(current_company_id, @date_start, @date_end, @options)
    @total_no_logouts.each_with_index do |no_logout, index|
      data_sheet.row(index+1).replace [no_logout[:person_name].titleize,
        no_logout[:department].blank? ? "" : no_logout[:department].just_display,
        no_logout[:division].blank? ? "" : no_logout[:division].just_display,
        no_logout[:position].blank? ? "" :no_logout[:position].just_display,
        "#{l no_logout[:date]}",
        no_logout[:start_work_session]? no_logout[:start_work_session].strftime("%H:%M") : "",
        no_logout[:end_work_session]? no_logout[:end_work_session].strftime("%H:%M") : "",
        no_logout[:is_acted_upon]? "-" : no_logout[:start_work_session].blank? ? "Tidak Absen Masuk" : "Tidak Absen Keluar"
      ]
    end unless @total_no_logouts.blank?
  end

  def set_data_export_absent_table(data_sheet)
    get_data_from_session
    @total_absents = Presence.who_is_not_working(current_company_id, @date_start, @date_end, @options)
    @total_absents.each_with_index do |absent, index|
      data_sheet.row(index+1).replace [absent[:person].full_name.titleize,
        absent[:department].blank? ? "" : absent[:department].department_name.just_display,
        absent[:division].blank? ? "" : absent[:division].name.just_display,
        "#{l absent[:date]}",
        absent[:type],
        absent[:leave_quota],
        absent[:total_permision],
        (!absent[:type].blank? or absent[:is_acted_upon])? absent[:reason] : "Belum ditindaklanjuti"
      ]
    end unless @total_absents.blank?
  end

  def set_data_export_absent_table(data_sheet)
    get_data_from_session
    @total_absents = Presence.who_is_not_working(current_company_id, @date_start, @date_end, @options)
    @total_absents.each_with_index do |absent, index|
      data_sheet.row(index+1).replace [absent[:person].full_name.titleize,
        absent[:department].blank? ? "" : absent[:department].department_name.just_display,
        absent[:division].blank? ? "" : absent[:division].name.just_display,
        "#{l absent[:date]}",
        absent[:type],
        absent[:leave_quota],
        absent[:total_permision],
        (!absent[:type].blank? or absent[:is_acted_upon])? absent[:reason] : "Belum ditindaklanjuti"
      ]
    end unless @total_absents.blank?
  end


  def set_data_export_less_rest_table(data_sheet)
    get_data_from_session
    @total_less_rests = Presence.breaktime_less_than_normal(current_company_id, @date_start, @date_end, @options)
    @total_less_rests.each_with_index do |more_rest, index|
      data_sheet.row(index+1).replace [more_rest[:person_name].titleize,
        more_rest[:department].blank? ? "" : more_rest[:department].just_display,
        more_rest[:division].blank? ? "" : more_rest[:division].just_display,
        "#{l more_rest[:date]}",
        Presence.minutes_to_hour_text(more_rest[:break_length]),
        more_rest[:is_acted_upon]? more_rest[:status] : "Belum ditindak lanjuti",
        more_rest[:description]
      ]
    end unless @total_less_rests.blank?
  end

  def set_data_export_more_rest_table(data_sheet)
    get_data_from_session
    @total_more_rests = Presence.breaktime_more_than_normal(current_company_id, @date_start, @date_end, @options)
    @total_more_rests.each_with_index do |more_rest, index|
      data_sheet.row(index+1).replace [more_rest[:person_name].titleize,
        more_rest[:department].blank? ? "" : more_rest[:department].just_display,
        more_rest[:division].blank? ? "" : more_rest[:division].just_display,
        "#{l more_rest[:date]}",
        Presence.minutes_to_hour_text(more_rest[:break_length]),
        more_rest[:is_acted_upon]? more_rest[:status] : "Belum ditindak lanjuti",
        more_rest[:description]
      ]
    end unless @total_more_rests.blank?
  end

  def set_data_export_less_hour_table(data_sheet)
    get_data_from_session
    @total_more_rests = Presence.breaktime_more_than_normal(current_company_id, @date_start, @date_end, @options)
    @total_more_rests.each_with_index do |more_hour, index|
      data_sheet.row(index+1).replace [more_hour[:person_name].titleize,
        more_hour[:department].blank? ? "" : more_hour[:department].just_display,
        more_hour[:division].blank? ? "" : more_hour[:division].just_display,
        "#{l more_hour[:date]}",
        more_hour[:start_work].blank? ? "" : more_hour[:start_work].strftime("%H:%M"),
        more_hour[:end_work].blank? ? "" : more_hour[:end_work].strftime("%H:%M"),
        Presence.hours_to_hour_text(more_hour[:work_length]),
        more_hour[:is_acted_upon]? more_hour[:status] : "Belum ditindak lanjuti"
      ]
    end unless @total_more_rests.blank?
  end

  def set_data_export_less_hour_table(data_sheet)
    get_data_from_session
    @total_less_hours = Presence.worktime_less_than_normal(current_company_id, @date_start, @date_end, @options)
    @total_less_hours.each_with_index do |more_hour, index|
      data_sheet.row(index+1).replace [more_hour[:person_name].titleize,
        more_hour[:department].blank? ? "" : more_hour[:department].just_display,
        more_hour[:division].blank? ? "" : more_hour[:division].just_display,
        "#{l more_hour[:date]}",
        more_hour[:start_work].blank? ? "" : more_hour[:start_work].strftime("%H:%M"),
        more_hour[:end_work].blank? ? "" : more_hour[:end_work].strftime("%H:%M"),
        Presence.hours_to_hour_text(more_hour[:work_length]),
        more_hour[:is_acted_upon]? more_hour[:status] : "Belum ditindak lanjuti"
      ]
    end unless @total_less_hours.blank?
  end


  def set_data_export_more_hour_table(data_sheet)
    get_data_from_session
    @total_more_hours = Presence.worktime_more_than_normal(current_company_id, @date_start, @date_end, @options)
    @total_more_hours.each_with_index do |more_hour, index|
      data_sheet.row(index+1).replace [more_hour[:person_name].titleize,
        more_hour[:department].blank? ? "" : more_hour[:department].just_display,
        more_hour[:division].blank? ? "" : more_hour[:division].just_display,
        "#{l more_hour[:date]}",
        more_hour[:start_work].blank? ? "" : more_hour[:start_work].strftime("%H:%M"),
        more_hour[:end_work].blank? ? "" : more_hour[:end_work].strftime("%H:%M"),
        Presence.hours_to_hour_text(more_hour[:work_length]),
        more_hour[:is_acted_upon]? more_hour[:status] : "Belum ditindak lanjuti"
      ]
    end unless @total_more_hours.blank?
  end

  def set_data_export_late_table(data_sheet)
    get_data_from_session
    @total_lates = Presence.late_comers(current_company_id, @date_start, @date_end, @options)
    @total_lates.each_with_index do |late, index|
      data_sheet.row(index+1).replace [late[:person_name].titleize,
        late[:department].blank? ? "" : late[:department].department_name.just_display,
        late[:division].blank? ? "" : late[:division].name.just_display,
        late[:shift_name].blank? ? "" : late[:shift_name].just_display,
        "#{l late[:date]}",
        late[:start_work].strftime("%H:%M"),
        Presence.minutes_to_hour_text(late[:late_time]),
        late[:late_reason],
        late[:is_acted_upon]? late[:status] : "Belum ditindak lanjuti"
      ]
    end unless @total_lates.blank?
  end

  def set_data_export_monthly_index_table(data_sheet)
    @options[:person] = true
    get_data_from_session
    @total_presences = Presence.who_is_working(current_company_id, @date_start, @date_end, @options)
    @total_presences.each_with_index do |presence, index|
      dept = presence.department(@date_end)
      div = presence.division(@date_end)
      leave = presence.absences.total_by_type([1,2,5,6], @date_start, @date_end, current_company_id)
      sick = presence.absences.total_by_type([3,7], @date_start, @date_end, current_company_id)
      awol = presence.absences.total_by_type([4], @date_start, @date_end, current_company_id)
      data_sheet.row(index+1).replace [presence.full_name.titleize,
        dept.blank? ? "" : dept.department_name.just_display,
        div.blank? ? "" : div.name.just_display,
        "#{presence.presences.total_attendance_days(@date_start.month, @date_start.year)}",
        "#{leave}","#{sick}","#{awol}"]
    end
    return data_sheet
  end

  def set_data_export_daily_index_table(data_sheet)
    get_data_from_session
    @total_presences = Presence.who_is_working(current_company_id, @date_start, @date_end, @options)
    @total_presences.each_with_index do |presence, index|
      the_person = presence.person
      the_presence_details = presence.presence_details
      data_sheet.row(index+1).replace [the_person.full_name.titleize,
        the_person.department(presence.presence_date).blank? ? "" : the_person.department(presence.presence_date).department_name.just_display,
        the_person.division(presence.presence_date).blank? ? "" : the_person.division(presence.presence_date).name.just_display ,
        the_presence_details.last.blank? ? "" : the_presence_details.first.start_working.blank? ? "" :  the_presence_details.first.start_working.getlocal.strftime("%H:%M"),
        the_presence_details.last.end_working.blank? ? "" : the_presence_details.last.end_working.getlocal.strftime("%H:%M"),
        Presence.minutes_to_hour_text(presence.break_length_in_minutes.to_i),
        Presence.hours_to_hour_text(presence.presence_length_in_hours.to_f - presence.moved_worktime_in_hours.to_f)]
    end
    return data_sheet
  end

  def get_duration_in_hour(num)
    num_ar = num.split("+")
    return (num_ar[1].to_f / 60) + num_ar[0].to_f
  end

  # prepare ini mau dihapus tanya dulu ke pa nanto karena berhubungan dengan keluar masuk absensi
  def prepare_myabsence
    unless params[:date].blank? || params[:date] == "undefined"
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    yesterday_presence = @current_person.presences.find_by_presence_date(@date.yesterday)
    my_last_presence = @current_person.presences.find(:first, :order => "presence_date DESC")
    if my_last_presence
      @my_last_presence_date = my_last_presence.presence_date
    else
      @my_last_presence_date = Date.yesterday
    end
    @my_presence = @current_person.presences.find_by_presence_date(@date)
    @yesterday_schedule = @current_person.current_schedule(Date.yesterday).blank? ? Date.yesterday.to_time : @current_person.current_schedule(Date.yesterday)[:schedule_end]
    if @my_presence
      @my_presence_details = @my_presence.presence_details(:order => :start_working)
    end
  end

  def prepare_myabsence2
    session[:conditions] = get_kond_prepare_my_absence
    @my_presence = @current_person.presences.find(:all, :conditions => current_conditions)
  end

  def start_end_date
    @date_start = (params[:date_start].blank? || params[:date_start]=="undefined") ? Date.today : Date.parse(params[:date_start])
    @date_end = (params[:date_end].blank? || params[:date_end]=="undefined") ? @date_start : Date.parse(params[:date_end])
  end

  def start_end_month
    if params[:date_month] && params[:date_start] != "undefined"
      @date_month = params[:date_month].to_i
      @date_year = params[:date_year].to_i
      @date_start = Date.civil(@date_year,@date_month)
    else
      @date_start = Date.today.at_beginning_of_month
    end
    if @date_start.at_end_of_month > Date.today
      @date_end = Date.today
    else
      @date_end = @date_start.at_end_of_month
    end
  end

  def start_end_month1
    if params[:date_start_year] && params[:date_start_month] != "undefined"
      @date_start_month = params[:date_start_month].to_i
      @date_start_year = params[:date_start_year].to_i
      @date_start = Date.civil(@date_start_year,@date_start_month)
    else
      @date_start = Date.today.at_beginning_of_month
    end
    if params[:date_end_year] && params[:date_end_month] != "undefined"
      @date_end_month = params[:date_end_month].to_i
      @date_end_year = params[:date_end_year].to_i
      date_end = Date.civil(@date_end_year,@date_end_month)
      @date_end = date_end.at_end_of_month
    else
      @date_end = Date.today.at_end_of_month
    end
  end

  def filter_options
    @options = {}
    name = params[:name] if params[:name] != "undefined"
    nik = params[:nik]
    department = params[:department].to_i
    division = params[:division].to_i
    contract = params[:contract].to_i
    unless name.blank?
      @options[:name] = name
      @options[:condition] = "(firstname LIKE '%#{name}%' OR lastname LIKE '%#{name}%' OR CONCAT(TRIM(firstname),' ',TRIM(lastname)) LIKE '%#{name}%')"
    end
    unless nik.blank?
      @options[:nik] = nik
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

  def current_company_person
    @departments = Department.all(:conditions => {:company_id => current_company_id}, :order => "department_name")
    @divisions = Division.all(:conditions => {:company_id => current_company_id}, :order => "name")
    if params[:id]
      @current_person = Person.find(:first, :conditions => {:id => params[:id].to_i, :company_id => current_company_id})
    end
    unless @current_person
      @current_person = Person.find_by_user_id(current_user.id)
    end
  end

  def set_data_to_session(str_action_name = nil)
    session[:url_act] = str_action_name unless str_action_name.blank?
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

  def get_kond_prepare_my_absence
    if !params[:date].blank? || !params[:date] == "undefined"
      date1 = params[:date]
      date2 = params[:date]
    elsif !params[:date1].blank? && !params[:date2].blank?
      date1 = Person.format_date(params[:date1])
      date2 = Person.format_date(params[:date2])
    end
    return "presence_date between '#{date1}' and '#{date2}'"
  end

end

