class JobAccidentsController < ApplicationController
  require 'gchart'
  layout "application2"

  ssl_required :check_features, :delete_multiple, :export
  before_filter :current_features
  before_filter :check_features, :only => [:index, :show, :edit, :new, :delete_multiple, :export]
  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('accident_index') ? true : invalid_features
    when "show"
      current_features.include?('accident_detail') ? true : invalid_features
    when "new"
      current_features.include?('accident_new') ? true : invalid_features
    when "edit"
      current_features.include?('accident_edit') ? true : invalid_features
    when "delete_multiple"
      current_features.include?('accident_delete') ? true : invalid_features
    when "export"
      current_features.include?('accident_export') ? true : invalid_features
    end
  end

  def index
    add_breadcrumb "Karyawan", "#person_index"
    add_breadcrumb "Kecelakaan Kerja", "#job_accidents"
    session[:url_act] = "job_accidents"
    prepare_index
    reload_page('list_job_accident', 'list_job_accidents', nil, 'ada')
  end

  def new
    @pers_id = params[:pers_id]
    if params[:pers_id].blank?
      @person =  Person.new
      add_breadcrumb "Karyawan", "#person_index"
      add_breadcrumb "Kecelakaan Kerja", "#job_accidents"
      add_breadcrumb "Tambah Kecelakaan Kerja", "#job_accidents/new"
    else
      @person = Person.find(params[:pers_id])
      add_breadcrumb "Karyawan", "#person_index"
      add_breadcrumb "Daftar karyawan", "#person_index"
      add_breadcrumb "Data Pekerjaan", "#people/#{@person.id}/employments?tab=0"
      add_breadcrumb "Tambah Kecelakaan kerja", "#job_accidents/new?pers_id=#{@person.id}"
    end
    @accident = Accident.new
    render :layout => false
  end

  def edit
    @pers_id = params[:pers_id]
    @accident = Accident.find(params[:id])
    @person = @accident.person
    unless @pers_id.blank?
      add_breadcrumb "Karyawan", "#person_index"
      add_breadcrumb "Daftar karyawan", "#person_index"
      add_breadcrumb "Data Pekerjaan", "#people/#{@pers_id}/employments?tab=0"
      add_breadcrumb "Edit Kecelakaan Kerja", "#memorandums/99/edit?pers_id=#{@pers_id}"
    else
      add_breadcrumb "Karyawan", "#person_index"
      add_breadcrumb "Kecelakaan Kerja", "#job_accidents"
      add_breadcrumb "Edit Kecelakaan Kerja", "#job_accidents/#{@accident.id}/edit"
    end
    render :layout => false
  end

  def create
    @accident = Accident.new(params[:accident].merge(:company_id => current_company_id))
    @person = Person.get_person_name_by_department_and_division(params[:accident][:person_name], current_company_id)
    @person = Person.find(params[:accident]['pers_id']) unless params[:accident]['pers_id'].blank?
    @accident.person_id = @person.blank? ? "" : @person.id
    if @accident.save
      flash.now[:notice] = "Kecelakaan kerja berhasil disimpan"
      if params[:accident][:pers_id].blank?
        prepare_index
        reload_page("div_index","index","job_accidents")
      else
        #redirect_to person_employments_path(params[:accident][:pers_id]) + "?tab=4"
        @person = Person.first(:conditions => ['id = ?', params[:accident][:pers_id]])
        add_breadcrumb "Karyawan", "#person_index"
        add_breadcrumb "Daftar karyawan", "#person_index"
        add_breadcrumb "Data Pekerjaan", "#people/#{@person.id}/employments?tab=0"
        @new = Employment.new
        @trainings = @person.trainings
        @violations = @person.violations
        @accidents = @person.accidents
        @contract = WorkContract.new
        @employment = @person.current_employment
        @employments = @person.employments(:order=>"id Desc")
        @id = @person.id
        kondisi = "id is null"
        unless @person.current_employment.blank?
          kondisi = "id <> #{@person.current_employment.id}" unless @person.current_employment.id.blank?
          @history = @employments.all(:conditions=> kondisi,:order=>"id Desc")
        end
        reload_page2('div_index','employments/index',"people/#{params[:accident][:pers_id]}/employments?tab=4")
      end
    else
      @person = Person.new
      @pers_id = params[:pers_id]
      @pers_id = params[:accident][:pers_id] if @pers_id.blank?
      @person = Person.find(@pers_id) unless @pers_id.blank?
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      reload_page("div_index","new")
    end
  end

  def update    
    @accident = Accident.find(params[:id])
    if @accident.update_attributes(params[:accident])
     flash.now[:notice] = "Kecelakaan kerja berhasil diupdate"
     if params[:accident][:pers_id].blank?
       prepare_index
       reload_page("div_index","index","job_accidents")
     else
       @person = Person.first(:conditions => ['id = ?', params[:accident][:pers_id]])
       add_breadcrumb "Karyawan", "#person_index"
       add_breadcrumb "Daftar karyawan", "#person_index"
       add_breadcrumb "Data Pekerjaan", "#people/#{@person.id}/employments?tab=0"
       @new = Employment.new
       @contract = WorkContract.new
       @trainings = @person.trainings
       @accidents = @person.accidents
       reload_page2('div_index','employments/index',"people/#{params[:accident][:pers_id]}/employments?tab=4")
     end
    else
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      @pers_id = params[:pers_id]
      @pers_id = params[:accident][:pers_id] if @pers_id.blank?
      @person = Person.find(@accident.person_id)      
      reload_page("div_index","edit")
    end
  end

  def delete_multiple
    flash.now[:notice] = "Kecelakaan kerja gagal dihapus"
    unless params[:ids].blank?
      id = params[:ids]
      accident = Accident.all(:conditions => "id in ('#{id.join("','")}')")
      accident.each do |f|
        f.destroy
      end      
      flash.now[:notice] = "Kecelakaan kerja berhasil dihapus"
    end
    prepare_index
    reload_page('div_index', 'index')
  end

  def get_data_person_in_autocomplete    
    @person = Person.get_person_name_by_department_and_division(params[:person_data], current_company_id)
    no_jamsotek = @person.blank? ? "tidak ada jamsotek" : @person.jamsostek_number.blank? ? "tidak ada jamsotek" : @person.jamsostek_number
    render :update do |page|
      page << "$('#jamsostek').html('#{no_jamsotek}')"
    end
  end 

  def export
    unless current_conditions.blank?
      @export_data = Accident.by_company(current_company_id).all(:conditions => current_conditions)
    else
      @export_data = Accident.by_company(current_company_id).all
    end
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "kecelakaan_kerja"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format

    data_sheet.row(0).replace ['Nama Karyawan','No.Jamsostek','Bagian', 'Tanggal', 'Penyebab',
      'Tindakan', 'Penanggung jawab', 'Kategori']
    @export_data.each_with_index do |data, index|
      person = Person.first(:conditions => "id = #{data.person_id}") unless data.person_id.blank?
      data_sheet.row(index+1).replace [ person.blank? ? "" : person.full_name, person.blank? ? "" : person.jamsostek_number,
        person.blank? ? "" : person.current_employment.blank? ? "" : person.current_employment.work_division_id.blank? ? "" : person.current_employment.division.name,
        data.accident_date, data.causes, data.action_taken, data.accident_person_in_charge, data.accident_category]
    end

    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "kecelakaan_kerja.xls", :type =>  "application/vnd.ms-excel"
  end

  private

  def prepare_index
    @per_page = 10
    if params[:filter].blank?
      @accidents = Accident.by_company(current_company_id).paginate({:page => params[:page], :per_page => @per_page, :include =>[:person], :order=> "people.firstname"})
      session[:conditions] = ""
    else
      kondisi = Accident.search_filter(params[:filter])
      session[:conditions] = kondisi
      @accidents = Accident.by_company(current_company_id).paginate({:page => params[:page], :per_page => @per_page, :include =>[:person], :order=> "people.firstname", :conditions => kondisi})
    end    
  end

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name, :object => @people
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
        end
      }
    end
  end

  def reload_page2(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name, :object => @people
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('#info_jabatan, #info_pelatihan, #info_pelanggaran, #info_kecelakaan, #info_work_contracts').hide();"
          page << "$('#info_kecelakaan').show();"
          page << "$('#arrow2').addClass('icons arrow_ico');"
					page << "$('#arrow4').removeClass('icons arrow_ico');"
					page << "$('#arrow4').addClass('icons drop_arrow_ico');"
          page << "$('#arrow1').removeClass('icons drop_arrow_ico');"
          page << "$('#arrow1').addClass('icons arrow_ico');"
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end


end
