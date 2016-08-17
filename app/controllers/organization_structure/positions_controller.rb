class OrganizationStructure::PositionsController < ApplicationController
#  ssl_required
  add_breadcrumb "Struktur Organisasi", "#organization_structure/departments"
  before_filter :which_position, :only => [:show, :edit, :update, :destroy]
  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :edit, :delete_multiple]
  before_filter :prepare_index, :only => [:index]
  # Check features accessability by user roles
  def check_features
    case params[:action]
      when "index"
        current_features.include?('position_index') ? true : invalid_features
      when "new"
        current_features.include?('position_new') ? true : invalid_features
      when "edit"
        current_features.include?('position_edit') ? true : invalid_features
      when "delete_multiple"
        current_features.include?('position_delete') ? true : invalid_features
    end
    # return true
  end

  def index
    add_breadcrumb "Jabatan", "#organization_structure/positions"
    reload_page('div_positions','list_positions',nil,'ada')
  end

  def new
    add_breadcrumb "Jabatan", "#organization_structure/positions"
    add_breadcrumb "Tambah Jabatan", "#new_position"
    @position = Position.new
    render :layout => false
  end

  def create
    @position = Position.new(params[:position])
    @position.company_id = current_company_id
    if @position.save
      flash.now[:notice] = 'Jabatan berhasil disimpan'
      prepare_index
      reload_page('div_index','index','organization_structure/divisions')
    else
      flash.now[:notice] = 'Maaf ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali!'
      reload_page('div_index','new')
    end
  end

  def edit
  end

  def show
    if @position
      add_breadcrumb "Jabatan", "#organization_structure/positions"
      add_breadcrumb "Detail Jabatan", "#organization_structure/positions/#{@position.id}"
      render :layout => false
    else
      render :nothing => true
    end
  end

  def update
    if @position and @position.update_attributes(params[:position])
      flash.now[:notice] = 'Jabatan berhasil diupdate'
      prepare_index
      reload_page('div_index','index','organization_structure/positions')
    else
      flash.now[:notice] = 'Jabatan tidak berhasil diubah !'
      reload_page('div_index','show')
    end
  end

  def delete_multiple
    flash.now[:notice] = "Jabatan gagal dihapus"
    unless params[:position_ids].blank?
      valid = true
      @positions = Position.find(params[:position_ids])
      flash.now[:notice] = "Jabatan "
      @positions.each do |position|
        if position.company_id == current_company_id
          unless position.destroy
            valid = false
            flash.now[:notice] << "#{position.position_name}, "
          end
        end
      end
      flash.now[:notice] << "gagal dihapus karena memiliki data yang terkait"
      flash.now[:notice] = "Jabatan berhasil dihapus" if valid
    end
    prepare_index
    reload_page('div_index','index')
  end

  private

  protected

  def which_position
    @position = Position.find(:first, :conditions => { :company_id => current_company_id, :id => params[:id] })
  end

  def prepare_index
    @per_page = 10
    conditions = []
    conditions << "company_id=#{current_company_id}"    
    conditions = Position.find_condition_filter(current_company_id, params[:filter]) unless params[:filter].blank?
    @get_positions = Position.find(:all, :conditions => conditions)
    @positions = @get_positions.paginate(:conditions => conditions, :order => "position_name", :page => params[:page], :per_page => @per_page)
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
