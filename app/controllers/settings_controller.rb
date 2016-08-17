class SettingsController < ApplicationController
  layout "application_setting"

  ssl_required :check_features, :cuti_sakit, :edit_cuti_sakit, :update_cuti_sakit, :create_cuti_sakit, :new_cuti_sakit, :sistem_shift, :delete_check_leave
  before_filter :current_features
  before_filter :check_features, :only => [:index, :edit, :cuti_sakit, :new_cuti_sakit, :edit_cuti_sakit, :delete_check_leave]
  # Check features accessability by user roles

  def check_features
    case params[:action]
    when "index"
      current_features.include?('hr_setting_index') ? true : invalid_features
    when "edit"
      current_features.include?('hr_setting_edit') ? true : invalid_features
      # App Setting - Cuti dan Ijin Sakit
    when "cuti_sakit"
      current_features.include?('leave_index') ? true : invalid_features
    when "new_cuti_sakit"
      current_features.include?('leave_new') ? true : invalid_features
    when "edit_cuti_sakit"
      current_features.include?('leave_edit') ? true : invalid_features
    when "delete_check_leave"
      current_features.include?('leave_delete') ? true : invalid_features
    end
    # return true
  end

  def index
    add_breadcrumb "Setting HR", "#settings"
    @hr = HrSetting.find_by_company_id(current_company_id)
    render :layout => false
  end

  def edit
    @hr = HrSetting.find(:first, :conditions => { :company_id => current_company_id, :id => params[:id] })
    if @hr
      add_breadcrumb "Setting hr", "#settings"
      add_breadcrumb "Edit Setting hr", "#st/edit/#{@hr.id}"
      render :layout => false
    else
      render :nothing => true
    end
  end

  def cuti_sakit
    prepare_index
    add_breadcrumb "Jenis Tidak Masuk", "#cuti_sakit"
    reload_page1('div_index','index_cuti_sakit','cuti_sakit')
  end

  def edit_cuti_sakit
    @leave = AbsenceType.find(:first, :conditions => { :company_id => current_company_id, :id => params[:id] })
    if @leave
      add_breadcrumb "Jenis Tidak Masuk", "#cuti_sakit"
      add_breadcrumb "Edit Jenis Tidak Masuk", "#sett/edit_cuti_sakit/#{@leave.id}"
      render :layout => false
    else
      render :nothing => true
    end
  end

  def update_cuti_sakit
    @leave = AbsenceType.find(:first, :conditions => { :company_id => current_company_id, :id => params[:id] })

    if @leave and @leave.update_attributes(params['leave'])
      if @leave.type_id > 7
        @leave.absence_type_name = params['leave']['absence_type_name']
        @leave.save
      end
      flash.now[:notice] = "Jenis tidak masuk berhasil diupdate"
      prepare_index
      reload_page1('div_index','index_cuti_sakit','cuti_sakit')
    else
      flash.now[:notice] = 'Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!'
      reload_page1('div_index','partial_edit_cuti_sakit')
    end
  end

  def create_cuti_sakit
    @leave = get_data_leave
    if @leave.save
      flash.now[:notice] = "Jenis tidak masuk berhasil disimpan"
      prepare_index
      reload_page1('div_index','index_cuti_sakit','cuti_sakit')
    else
      flash.now[:notice] = 'Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!'
      reload_page1('div_index','partial_new_cuti_sakit')
    end

  end

  def new_cuti_sakit
    add_breadcrumb "Jenis Tidak Masuk", "#cuti_sakit"
    add_breadcrumb "Tambah Jenis Tidak Masuk", "#new_cuti_sakit"
    render :layout => false
  end

  def sistem_shift
    render :layout => "application_setting"
  end

  def update
    @hr = HrSetting.find(:first, :conditions => { :company_id => current_company_id, :id => params[:id] })
    if @hr and @hr.update_attributes(params["hr_setting"])
      flash.now[:notice] = "Data setting HR berhasil disimpan"
      reload_page('div_edit','index','settings')
    else
      flash.now[:notice] = "Mohon Mengisi Semua Data Yang Diperlukan"
      reload_page('div_edit','edit')
    end
  end

  def delete_multiple
    flash.now[:notice] = "Jenis tidak masuk gagal dihapus"
    unless params[:ids].blank?
      valid = true
      temp = AbsenceType.find_all_by_id_and_company_id(params[:ids], current_company_id)
      flash.now[:notice] = "Jenis tidak masuk "
      temp.each do |x|
        unless x.destroy
          valid = false
          flash.now[:notice] << "#{x.absence_type_name}, "
        end
        flash.now[:notice] << "gagal dihapus karena memiliki data yang terkait"
        flash.now[:notice] = "Jenis tidak masuk berhasil dihapus" if valid
      end
    end
    prepare_index
    reload_page1('div_index','index_cuti_sakit')
  end

  private

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name, :object => @hr
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def reload_page1(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name, :object => @leave
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "parent.$.fn.colorbox.close();"
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def get_data_leave
    leave = AbsenceType.new(params['leave'])
    leave.type_id = AbsenceType.maximum(:type_id) + 1
    leave.absence_type_name = params['leave']['absence_type_name']
    leave.company_id = current_company_id
    leave.count_as_leave = params['count_as_leave'].to_i
    leave.is_salary_paid = params['is_salary_paid'].to_i
    leave.allowance_are_paid = params['allowance_are_paid'].to_i
    return leave
  end

  def prepare_index
    @per_page = 10
    @leave = AbsenceType.find(:all, :conditions => ["company_id = ?" ,current_company_id]).paginate({:page => params[:page], :per_page => @per_page})
  end


end

