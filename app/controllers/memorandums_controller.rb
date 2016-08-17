class MemorandumsController < ApplicationController
  require 'gchart'
  layout  "application2"

  ssl_required :check_features, :delete_multiple, :export
  before_filter :current_features
  before_filter :check_features, :only => [:index, :show, :edit, :new, :delete_multiple, :export]
  before_filter :prepare_index, :only => [:index]
  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('sp_index') ? true : invalid_features
    when "show"
      current_features.include?('sp_detail') ? true : invalid_features
    when "new"
      current_features.include?('sp_new') ? true : invalid_features
    when "edit"
      current_features.include?('sp_edit') ? true : invalid_features
    when "delete_multiple"
      current_features.include?('delete_sp') ? true : invalid_features
    when "export"
      current_features.include?('sp_export') ? true : invalid_features

    end
    # return true
  end

  def index
    add_breadcrumb "Karyawan", "#person_index"
    add_breadcrumb "Surat Peringatan", "#memorandums"
    session[:url_act] = "memorandums"
    reload_page('list_memorandum', 'list_memorandums', nil, "stop_filter")
  end

  def new
    @pers_id = params[:pers_id]
    if params[:pers_id].blank?
      @person = Person.new
      add_breadcrumb "Karyawan", "#person_index"
      add_breadcrumb "Surat Peringatan", "#memorandums"
      add_breadcrumb "Tambah Surat Peringatan", "#memorandums/new"
    else      
      @person = Person.find(params[:pers_id])
      add_breadcrumb "Karyawan", "#person_index"
      add_breadcrumb "Daftar karyawan", "#person_index"
      add_breadcrumb "Data Pekerjaan", "#people/#{@person.id}/employments?tab=0"
      add_breadcrumb "Tambah Surat peringantan", "#memorandums/new?pers_id=#{@person.id}"
    end
    @violation = Violation.new
    render :layout => false
  end

  def edit    
    @violation = Violation.find(params[:id])
    @pers_id = params[:pers_id]
    @person = Person.find_by_id(@violation.person_id)
    unless @pers_id.blank?
      add_breadcrumb "Karyawan", "#person_index"
      add_breadcrumb "Daftar karyawan", "#person_index"
      add_breadcrumb "Data Pekerjaan", "#people/#{@pers_id}/employments?tab=0"
      add_breadcrumb "Edit Surat peringantan", "#memorandums/99/edit?pers_id=#{@pers_id}"
    else
      add_breadcrumb "Karyawan", "#person_index"
      add_breadcrumb "Surat Peringatan", "#memorandums"
      add_breadcrumb "Edit Surat Peringatan", "#memorandums/#{@violation.id}/edit"
    end
    render :layout => false
  end

  def update
    @violation = Violation.find(params[:id])
    if @violation.update_attributes(params[:violation])
      flash.now[:notice] = "Data peringatan/pelanggaran berhasil diupdate"
      if params[:violation][:pers_id].blank?
        prepare_index
        reload_page("div_index","index","memorandums")
      else
        @person = Person.first(:conditions => ['id = ?', params[:violation][:pers_id]])
        add_breadcrumb "Karyawan", "#person_index"
        add_breadcrumb "Daftar karyawan", "#person_index"
        add_breadcrumb "Data Pekerjaan", "#people/#{@person.id}/employments?tab=0"
        @new = Employment.new
        @contract = WorkContract.new
        @trainings = @person.trainings
        @violations = @person.violations
        reload_page2('div_index','employments/index',"people/#{@person.id}/employments?tab=3")
      end
    else
      @pers_id = params[:pers_id]
      @pers_id = params[:violation][:pers_id] if @pers_id.blank?
      @person = Person.find(@violation.person_id)
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      reload_page("div_index","edit")
    end
  end

  def create
    @violation = Violation.new(params[:violation].merge(:company_id => current_company_id))
    @person = Person.get_person_name_by_department_and_division(params[:violation][:person_name], current_company_id)
    @person = Person.find(params[:violation]['pers_id']) unless params[:violation]['pers_id'].blank?
    @violation.person_id = @person.blank? ? "" : @person.id
    if @violation.save
      flash.now[:notice] = "Data peringatan/pelanggaran berhasil disimpan"
      if params[:violation][:pers_id].blank?
        prepare_index
        reload_page("div_index","index","memorandums")
      else
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
        reload_page2('div_index','employments/index',"people/#{params[:violation][:pers_id]}/employments?tab=3")
      end
    else
      @person = Person.new
      @pers_id = params[:pers_id]
      @pers_id = params[:violation][:pers_id] if @pers_id.blank?
      @person = Person.find(@pers_id) unless @pers_id.blank?
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      reload_page("div_index","new", nil ,"loader")
    end
  end

  def delete_multiple
    flash.now[:notice] = "Data peringatan/pelanggaran gagal dihapus"
    unless params[:ids].blank?
      violation = Violation.all(:conditions => "id in ('#{params[:ids].join("','")}')")
      violation.each do |f|
        f.destroy
      end
      flash.now[:notice] = "Data peringatan/pelanggaran berhasil dihapus"
    end
    prepare_index
    reload_page('div_index','index',"memorandums")
  end

  def export
    unless current_conditions.blank?
      @export_data = Violation.by_company(current_company_id).all(:conditions => current_conditions)
    else
      @export_data = Violation.by_company(current_company_id).all
    end
    workbook = Spreadsheet::Workbook.new
    data_sheet = workbook.create_worksheet :name => "surat_peringatan"
    format = Spreadsheet::Format.new :weight => :bold
    data_sheet.row(0).default_format = format

    data_sheet.row(0).replace [ 'Nama Karyawan', 'Jenis SP', 'Kategori Pelanggaran', 'Tgl SP Diberikan',
      'SP berlaku sampai', 'Keterangan']
    #
    @export_data.each_with_index do |data, index|
      data_sheet.row(index+1).replace [ data.person.full_name, data.action_taken, data.violation_category,
        data.occurence_date, data.active_until, data.violation_description]
    end

    spreadsheet = StringIO.new
    workbook.write spreadsheet
    send_data spreadsheet.string, :filename => "surat_peringatan.xls", :type =>  "application/vnd.ms-excel"
  end

  private

  def prepare_index
    @per_page = 20
    if params[:filter].blank?
      @violations = Violation.by_company(current_company_id).paginate(:include =>[:person], :order=> "people.firstname",:page => params[:page], :per_page => @per_page)
      session[:conditions] = ""
    else
      kondisi = Violation.search_filter(params[:filter])
      session[:conditions] = kondisi
      @violations = Violation.by_company(current_company_id).paginate(:include =>[:person], :order=> "people.firstname",:page => params[:page], :per_page => @per_page, :conditions => kondisi)
    end
  end

  def get_person_name_by_department_and_division(nama)
  end

  def name_split(nama)
    data = nama.split(",")
    return data
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
          page << "removeNotifyMessage();"
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
          page << "$('#info_pelanggaran').show();"
          page << "$('#arrow2').addClass('icons arrow_ico');"
					page << "$('#arrow3').removeClass('icons arrow_ico');"
					page << "$('#arrow3').addClass('icons drop_arrow_ico');"
          page << "$('#arrow1').removeClass('icons drop_arrow_ico');"
          page << "$('#arrow1').addClass('icons arrow_ico');"
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

end
