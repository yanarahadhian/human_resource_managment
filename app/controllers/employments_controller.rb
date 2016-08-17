require 'pp'
class EmploymentsController < ApplicationController
  #before_filter :login_required
  add_breadcrumb "Karyawan", "#person_index"
  before_filter :value, :except => [:index]
  before_filter :initial_value, :only => [:new, :create, :edit, :update]
  before_filter :initial_work_contract, :only => [:create_work_contract,:update_work_contract, :cancel_work_contract, :destroy_work_contract]
  before_filter :prepare_index, :only => [:index, :update,:cancel]
  before_filter :position_and_work_assigned_values

  ssl_required :history_jabatan, :create_work_contract, :update_work_contract, :cancel_work_contract, :destroy_work_contract,
    :cancel, :change_divisi, :change_group, :popup_add_employment, :popup_detail_employment, :cancel_popup_detail, :popup_edit_employment
  def index
    add_breadcrumb "Daftar karyawan", "#person_index"
    add_breadcrumb "Data Pekerjaan", "#people/#{@person.id}/employments?tab=0"
    @trainings = @person.trainings
    @violations = @person.violations
    @accidents = @person.accidents
    @new = Employment.new
    @contract = WorkContract.new
    render :layout => false
  end

  def history_jabatan
    @person = Person.find(params[:person_id])
    @employment = @person.current_employment
    @employments = @person.employments(:order=>"id Desc")
    @new = Employment.new
    render :layout => false
  end

  def show
    @employment = Employment.find(params[:id])
  end

  def new
    if params[:act] == 'tambah'
      @employment = Employment.new
    else
      unless @last_employment.employment_end.blank?
        @new_employment_start = @last_employment.employment_end.dup
      else
        @new_employment_start = Date.today
      end
      @new_employment_end = @new_employment_start.advance(:years => 1)
      if @value == 'Mutasi'
        @employment = Employment.new(@last_employment.attributes.merge('id' => '','work_assigned' => '','employment_start' => @new_employment_start, 'employment_end' => @new_employment_end))
      elsif @value == 'Promosi' || @value == 'Demosi'
        @employment = Employment.new(@last_employment.attributes.merge('id' => '','position' => '','employment_start' => @new_employment_start, 'employment_end' => @new_employment_end))
      elsif @value == 'Termination'
        @employment = Employment.edit(@person)
      elsif @value == 'Extension'
        @employment = Employment.new(@last_employment.attributes.merge('id' => '','employment_start' => @new_employment_start, 'employment_end' => @new_employment_end))
      end
    end
  end

  def create
    param = Employment.param_str_to_date(params[:employment])
    @employment = Employment.new(param.merge({:person_id => @person.id,
          :previous_employment_id => @last_employment.blank? ? nil : @last_employment.id}))

    save_new_division if params[:division_name]

    if @employment.save
      @person.update_attribute(:latest_employment_id, @employment.id)
       save = "create_employments"
      if @employment.change_from_before == "terminasi"
        copy_previous_employment
        save = "terminasi"
      end
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#people/#{@person.id}/employments?tab=0&save=#{save}';</script></body></html>"
    else
      @new = Employment.new
      render :layout=> false, :action => :popup_add_employment
    end
  end

  def edit
    @employment = Employment.find(params[:id])
  end

  def update
    param = Employment.param_str_to_date(params[:employment])
    @employment = Employment.find(params[:id])
    if @employment.update_attributes(param)
      if @employment.id == @employment.person.latest_employment_id
        @employment.person.update_attribute(:employment_date, @employment.employment_start)
      end
      flash.now[:notice] = "Data karyawan berhasil diubah"
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#people/#{@person.id}/employments?tab=0&save=update_employments';</script></body></html>"
    else
      a = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      a =  "#{a}<br> #{@employment.errors[:employment_end]}<br>#{@employment.errors[:employment_start]}"
      flash.now[:notice] = a
      @sign = "gagal"
      render :layout=> false, :action => :popup_detail_employment
    end

  end

  def create_work_contract
    if params[:contract]['contract_type_id'] == "lainnya"
      contract_type = ContractType.first(:conditions => "contract_type_name='#{params[:contract]['contract_name']}' AND company_id=#{current_company_id}")
      contract_type = ContractType.create(:contract_type_name => params[:contract]['contract_name'],:company_id => current_company_id) if contract_type.blank?
      params[:contract]['contract_type_id'] = contract_type.id
    end
    @contract = WorkContract.new(params[:contract].merge(:previous_work_contract_id => @last_work_contract.blank? ? nil : @last_work_contract.id))
    @contract.company_id = current_company_id
    if @contract.save
      @person.update_attribute(:latest_work_contract_id, @contract.id)
      contract_type =  ""
      contract_type =  @contract.contract_type.contract_type_name unless @contract.contract_type.blank?
      flash.now[:notice] = "Data kontrak kerja berhasil disimpan"
      load_page("div_work_contract", "work_contracts/list_work_contracts")
    end
  end

  def update_work_contract
    if params[:contract]['contract_type_id'] == "lainnya"
      contract_type = ContractType.first(:conditions => "contract_type_name='#{params[:contract]['contract_name']}' AND company_id=#{current_company_id}")
      contract_type = ContractType.create(:contract_type_name => params[:contract]['contract_name'],:company_id => current_company_id) if contract_type.blank?
      params[:contract]['contract_type_id'] = contract_type.id
    end
    @contract = WorkContract.find(params[:id])
    if @contract.update_attributes(params[:contract])
      flash.now[:notice] = "Data kontrak kerja berhasil diupdate"
      load_page("div_work_contract", "work_contracts/list_work_contracts")
    end
  end

  def cancel_work_contract
    @contract = WorkContract.find(params[:id])    
    load_page("div_work_contract", "work_contracts/list_work_contracts")
  end

  def destroy_work_contract
    @contract = WorkContract.find_by_id(params[:id])
    unless @contract.blank?
      @contract.destroy       
      flash.now[:notice] = "Data kontrak kerja berhasil dihapus"
    end
    @contract = WorkContract.new
    load_page("div_work_contract", "work_contracts/list_work_contracts")
  end

  def cancel
    load_page('div_employment', 'data_employment')
  end

  def change_divisi
    @view = params[:view].blank?? "" : params[:view]
    @divisions = params[:id].blank?? "" :
      Division.by_company(current_company_id).all(:conditions=> "department_id=#{params[:id]}")
    div_section = "div_divisi"
    div_section = "div_divisi_absensi" if params[:view]=="view_absensi"
    div_section = "div_divisi_formasi" if params[:type]=="report_formasi"
    div_section = "div_divisi_formasi_jabatan" if params[:type]=="report_formasi_jabatan"
    div_section = "div_divisi_formasi_departemen" if params[:type]=="report_formasi_departemen"
    div_section = "div_divisi_formasi_bagian" if params[:type]=="report_formasi_bagian"
    render :update do |page|
      page.replace_html div_section, :partial=> 'employments/divisi_data', :locals=>{:type => params[:type] }
      if @divisions.blank?
        page << "$('#div_divisi').hide()"
      else
        page << "$('#div_divisi').show()"
      end
    end
  end

  def change_group
    @view = ""
    @view = params[:view] if params[:view]
    unless params[:id].blank?
      @groups = WorkGroup.all(:conditions=> "division_id=#{params[:id]}")
    else
      @groups = []
    end
    render :update do |page|
      page.replace_html 'div_group', :partial => 'group_data'
      if @groups.blank?
        page << "$('#div_group').hide()"
      else
        page << "$('#div_group').show()"
      end
    end
  end

  def popup_add_employment
    @person = Person.find(params[:person_id])
    @new = Employment.new
    render :layout => false
  end

  def popup_detail_employment
    @person = Person.find(params[:person_id])
    @employment = Employment.find(params[:id])
    render :layout => false
  end

  def popup_terminasi
    @person = Person.find(params[:person_id])
    @new = Employment.new
    #render layout => false#
    render :layout => false
  end

  def cancel_popup_detail
    @person = Person.find(params[:person_id])
    @employment = Employment.find(params[:id])
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html "div_edit_employment_form", :partial=> 'edit_form'
        end
      }
    end
  end

  def popup_edit_employment
    @employment = Employment.find(params[:id])
    render :layout => false
  end

  private

  def prepare_index
    initial_value
    @employment = @person.current_employment
    @employments = @person.employments(:order=>"id Desc")
    kondisi = "id is null"
    unless @person.current_employment.blank?
      kondisi = "id <> #{@person.current_employment.id}" unless @person.current_employment.id.blank?
      @history = @employments.all(:conditions=> kondisi,:order=>"id Desc")
    end
  end

  def copy_previous_employment
    employment = Employment.find(@employment.previous_employment_id)
    unless employment.blank?
      @employment.position_id = employment.position_id
      @employment.work_group_id = employment.work_group_id
      @employment.work_division_id = employment.work_division_id
      @employment.department_id = employment.department_id
      @employment.save
    end
  end

  def position_and_work_assigned_values
    #@position = Employment.find(:all, :select => "distinct position").collect{|emp| emp.position }.join(',')
    #@work_assigned = Employment.find(:all, :select => "distinct work_assigned").collect{|emp| emp.work_assigned}.join(',')
  end

  def value
    return @value = (params[:commit] || params[:change_from_before])
  end

  def initial_value
    if params[:person_id]
      @person = Person.find(params[:person_id])
    elsif params[:employment][:person_id]
      @person = Person.find(params[:employment][:person_id])
    end
    @last_employment = Employment.find_by_id(@person.latest_employment_id)
  end

  def initial_work_contract
    if params[:person_id]
      @person = Person.find(params[:person_id])
    elsif params[:contract][:person_id]
      @person = Person.find(params[:contract][:person_id])
    end
    @last_work_contract = WorkContract.find_by_id(@person.latest_work_contract_id)
  end

  def save_new_division
    division = Division.create(:name => params[:division_name])
    @employment.work_division_id = division.id
  end

  def reload_redirect_page(p_url)
    respond_to do |format|
     format.html { redirect_to(p_url, :notice => flash.now[:notice]) }
     format.js {
       render :update do |page|
          page << "parent.$.fn.colorbox.close()"
          page.replace_html "div_index", :partial=> "index"
          page.replace_html "div_new_sp", :partial=> "employments/index"
          page << "$('.notify_error').show();$('.message').html(#{flash.now[:notice]});" unless flash.now[:notice].blank?
       end
     }
    end
  end

  def load_page(div_name, partial_name)
    render :update do |page|
      page.replace_html div_name, :partial => partial_name
      page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')"  unless flash.now[:notice].blank?
    end
  end
  
end

