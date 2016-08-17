class OrganizationStructure::DepartmentsController < ApplicationController
#  before_filter :login_required
  add_breadcrumb "Struktur Organisasi", "#organization_structure/departments"
  before_filter :which_department, :only => [:show, :edit, :update, :destroy]
  before_filter :init_department, :only => [:new, :create]
  before_filter :prepare_index, :only => [:index]

#  ssl_required
  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :edit, :delete_multiple]
  # Check features accessability by user roles
  def check_features
    case params[:action]
      when "index"
        current_features.include?('department_index') ? true : invalid_features
      when "new"
        current_features.include?('department_new') ? true : invalid_features
      when "edit"
        current_features.include?('department_edit') ? true : invalid_features
      when "delete_multiple"
        current_features.include?('department_delete') ? true : invalid_features
    end
    # return true
  end

  def index
    add_breadcrumb "Department", "#organization_structure/departments"
    reload_page('div_department','list_departments',nil,'ada')
  end

  def show
    add_breadcrumb "Departemen", "#organization_structure/departments"
    add_breadcrumb "Detail Departemen", "#organization_structure/departments/#{params[:id]}"
    render :layout => false
  end

  def new
    add_breadcrumb "Departemen", "#organization_structure/departments"
    add_breadcrumb "Tambah Departemen", "#organization_structure/departments/new"
    render :layout => false
  end

  def create
    @department.attributes = params[:department]
    @department.company_id = current_company_id
    if @department.save
      flash.now[:notice] = "Departemen berhasil disimpan"
      prepare_index
      reload_page('div_index','index','organization_structure/departments')
    else
      flash.now[:notice] = 'Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!'
      reload_page('div_index','new')
    end
  end

  def edit
    render :layout => false
  end

  def update
    if @department && @department.update_attributes(params[:department])
      flash.now[:notice] = "Departemen berhasil diupdate"
      prepare_index
      reload_page('div_index','index','organization_structure/departments')
    else
      flash.now[:notice] = 'Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!'
      reload_page('div_index','show')
    end
  end

  def delete_multiple
    flash.now[:notice] = "Departemen gagal dihapus!"
    unless params[:department_ids].blank?
      valid = true
      @departments = Department.find(:all, :conditions => {:id => params[:department_ids], :company_id => current_company_id})
      flash.now[:notice] = "Departemen "
      @departments.each do |department|
        unless department.destroy
          valid = false
          flash.now[:notice] << "#{department.department_name}, "
        end
      end
      flash.now[:notice] << "gagal dihapus karena memiliki data yang terkait"
      flash.now[:notice] = "Departemen berhasil dihapus" if valid
    end
    prepare_index
    reload_page('div_index','index')
  end

  protected

  def prepare_index
    @per_page = 10
    conditions = "company_id=#{current_company_id}"
    conditions = Department.find_condition_filter(current_company_id, params[:filter]) unless params[:filter].blank?
    @get_departments = Department.find(:all, :conditions => conditions)
    @departments = @get_departments.paginate(:conditions => conditions, :order=>"department_name", :page => params[:page], :per_page => @per_page)
  end

  def init_department
    @department = Department.new
  end

  def which_department
    @department = Department.first(:conditions => {:id => params[:id].to_i,:company_id => current_company_id})
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
          page << "edit_info()" if params[:action]=="update"
          page << "removeNotifyMessage();"
        end
      }
    end
  end

end

