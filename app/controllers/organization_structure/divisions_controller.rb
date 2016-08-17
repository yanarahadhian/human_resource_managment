class OrganizationStructure::DivisionsController < ApplicationController
  add_breadcrumb "Struktur Organisasi", "#organization_structure/departments"
  before_filter :departments_list
  before_filter :initialize_division, :only => [:new, :create]
  before_filter :which_division, :only => [:edit, :update, :show]

  #  ssl_required
  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :edit, :destroy, :delete_multiple]
  before_filter :prepare_index, :only => [:index]
  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('division_index') ? true : invalid_features
    when "new"
      current_features.include?('division_new') ? true : invalid_features
    when "edit"
      current_features.include?('division_edit') ? true : invalid_features
    when "destroy"
      current_features.include?('division_delete') ? true : invalid_features
    when "delete_multiple"
      current_features.include?('division_delete') ? true : invalid_features
    end
  end

  def index
    add_breadcrumb "Bagian", "#organization_structure/divisions"
    reload_page('div_division','list_divisions',nil,'ada')
  end

  def show
    add_breadcrumb "Bagian", "#organization_structure/divisions"
    add_breadcrumb "Detail Bagian", "#organization_structure/divisions/#{params[:id]}"
    render :layout => false
  end

  def new
    add_breadcrumb "Bagian", "#organization_structure/divisions"
    add_breadcrumb "Tambah Bagian", "#organization_structure/divisions/new"
    render :layout => false
  end

  def create
    @division.attributes = params[:division]
    @division.company_id = current_company_id
    if @division.save
      flash.now[:notice] = 'Bagian berhasil disimpan'
      prepare_index
      reload_page('div_index','index','organization_structure/divisions')
    else
      flash.now[:notice] = 'Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!'
      reload_page('div_index','new')
    end
  end

  def edit
    render :layout => false
  end

  def update
      # is_approved(params[:username], params[:password]) &&
      # Commented due to role approval cek didn't exist
   if @division && @division.update_attributes(params[:division])
     flash.now[:notice] = "Bagian berhasil diupdate"
     prepare_index
     reload_page('div_index','index','organization_structure/divisions')
   else
     flash.now[:notice] = 'Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!'
     reload_page('div_index','show')
   end
  end

  def delete_multiple
    flash.now[:notice] = "Bagian gagal dihapus!"
    unless params[:division_ids].blank?
      valid = true
      @divisions = Division.find(:all, :conditions => {:id => params[:division_ids], :company_id => current_company_id})
      flash.now[:notice] = "Bagian "
      @divisions.each do |division|
        unless division.destroy
          valid = false
          flash.now[:notice] << "#{division.name}, "
        end
      end
      flash.now[:notice] << "gagal dihapus karena memiliki data yang terkait"
      flash.now[:notice] = "Bagian berhasil dihapus" if valid
    end
    prepare_index
    reload_page('div_index','index')
  end

  protected

  def prepare_index
    @per_page = 10
    conditions = []
    conditions << "company_id=#{current_company_id}"
    conditions = Division.find_condition_filter(current_company_id, params[:filter]) unless params[:filter].blank?
    if params[:department_id]
      conditions[0] << " AND department_id = ?"
      conditions << params[:department_id].to_i
    end
    @get_divisions = Division.find(:all, :conditions => conditions)
    @division = @get_divisions.paginate(:conditions => conditions, :order => "name", :page => params[:page], :per_page => @per_page )
  end

  def initialize_division
    @division = Division.new
  end

  def which_division
    @division = Division.first(:conditions => {:id => params[:id].to_i,:company_id => current_company_id})
  end

  def departments_list
    @departments = Department.find(:all, :conditions => {:company_id => current_company_id})
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

