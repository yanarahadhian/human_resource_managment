class OrganizationStructure::WorkGroupsController < ApplicationController
  add_breadcrumb "Struktur Organisasi", "#organization_structure/departments"
  before_filter :departments_list
  before_filter :initialize_group, :only => [:new, :create]
  before_filter :which_group, :only => [:edit, :update, :destroy, :show]

  #  ssl_required
  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :edit, :delete_multiple]
  before_filter :prepare_index, :only => [:index]
  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('group_index') ? true : invalid_features
    when "new"
      current_features.include?('group_new') ? true : invalid_features
    when "edit"
      current_features.include?('group_edit') ? true : invalid_features
    when "delete_multiple"
      current_features.include?('group_delete') ? true : invalid_features
    end
    # return true
  end

  def index
    add_breadcrumb "Work Group", "#organization_structure/work_groups"
    reload_page('div_groups','list_groups',nil,'ada')
  end

  def new
    add_breadcrumb "Work Group", "#organization_structure/work_groups"
    add_breadcrumb "Tambah Work Group", "#organization_structure/work_groups/new"
    render :layout => false
  end

  def show
    add_breadcrumb "Work Group", "#organization_structure/work_groups"
    add_breadcrumb "Detail Work Group", "#organization_structure/work_groups/#{params[:id]}"
    render :layout => false
  end

  def create
    @group = WorkGroup.new(params[:work_group])
    @group.company_id = current_company_id
    @group.division = Division.find(params[:division][:id]) unless params[:division][:id].blank?
    if @group.save
      flash.now[:notice] = 'Grup berhasil disimpan'
      prepare_index
      reload_page('div_index','index','organization_structure/work_groups')
    else
      flash.now[:notice] = 'Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!'
      reload_page('div_index','new')
    end
  end

  def update_divisions_list
    if params[:id]
      @division = Division.find(params[:id])
      @personels = @division.personel
      unless @personels.blank?
        render :update do |page|
          page.replace_html 'division_list_form', :partial => 'division_name'
        end
      else
        render :update do |page|
          page.replace_html 'division_list_form', ""
        end
      end
    end
  end

  def edit
    render :layout => false
  end

  def update
    if @group.update_attributes(params[:work_group])
      flash.now[:notice] = 'Group berhasil diupdate'
      prepare_index
      reload_page('div_index','index','organization_structure/work_groups')
    else
      flash.now[:notice] = 'Bagian tidak berhasil diubah!'
      reload_page('div_index','show')
    end
  end

  def delete_multiple
    flash.now[:notice] = "Group gagal dihapus"
    unless params[:work_group_ids].blank?
      valid = true
      @work_groups = WorkGroup.find(params[:work_group_ids])
      flash.now[:notice] = "Group "
      @work_groups.each do |work_group|
        unless work_group.destroy
          valid = false
          flash.now[:notice] << "#{work_group.work_group_name}, "
        end
      end
      flash.now[:notice] << "gagal dihapus karena memiliki data yang terkait"
      flash.now[:notice] = "Group berhasil dihapus" if valid
    end
    prepare_index
    reload_page('div_index','index')
  end

  protected

  def prepare_index
    @per_page = 10
    conditions = []
    conditions << "company_id=#{current_company_id}"
    unless params[:filter].blank?
      conditions = WorkGroup.find_condition_filter(current_company_id, params[:filter])
    end
    if params[:division_id]
      conditions[0] << " AND division_id = ?"
      conditions << params[:division_id].to_i
    end
    @get_groups = WorkGroup.find(:all, :conditions => conditions)
    @work_group = @get_groups.paginate(:conditions => conditions, :order => "work_group_name", :page => params[:page], :per_page => @per_page)
  end


  def initialize_group
    @group = WorkGroup.new
  end

  def which_group
    @group = WorkGroup.first(:conditions => {:id => params[:id].to_i,:company_id => current_company_id})
  end

  def departments_list
    # Temporary before have @current_company
    @departments = Department.find(:all, :conditions => {:company_id => current_company_id})
    @divisions = Division.find(:all, :conditions => {:company_id => current_company_id})
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
