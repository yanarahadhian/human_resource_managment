class FingerprintSettingsController < ApplicationController
  add_breadcrumb "Fingerprint", "#fingerprint_settings"
  before_filter :login_required
  before_filter :which_device, :only => [:show, :edit, :update, :delete_device_data]

  ssl_required :device_presence, :reload_page
  #  before_filter :current_features
  #  before_filter :check_features

  def index
    @devices = FingerprintDevice.all(:conditions => ['company_id = ?', current_company_id]).paginate({:page => params[:page], :per_page => 10})
    #    render :layout => false
    reload_page('div_fingerprint','index','fingerprint_settings')
  end

  def new
    add_breadcrumb "Tambah Fingerprint", "#fingerprint_settings/new"
    render :layout => false
  end

  def create
    unless params[:fingerprint_setting].blank?
      @devices = FingerprintDevice.new
      @devices.company_id = current_company_id
      @devices.device_name = params[:fingerprint_setting][:device_name]
      @devices.ip_address = params[:fingerprint_setting][:ip_address]
      @devices.port = params[:fingerprint_setting][:port].to_i if params[:fingerprint_setting][:port].to_i > 0
      if @devices.save
        flash.now[:notice] = "Data alat sidik jari berhasil disimpan"
        @devices = FingerprintDevice.find(:all, :conditions => ['company_id = ?' , current_company_id]).paginate({:page => params[:page], :per_page => 10})
        reload_page('div_fingerprint','index','fingerprint_settings')
      else
        flash.now[:notice] = "Data alat sidik jari tidak berhasil disimpan"
        reload_page('div_fingerprint','new')
      end
    end
  end

  def edit
    add_breadcrumb "Show Fingerprint", "#fingerprint_settings/#{@device.id}"
    add_breadcrumb "Edit Fingerprint", "#fingerprint_settings/#{@device.id}/edit"
    render :layout => false
  end

  def show
    @per_page = 10
    @device_logs = @device.fingerprint_device_access_logs.all(:order => "access_time desc").paginate({:page => params[:page], :per_page => @per_page})
    add_breadcrumb "Show Fingerprint", "#fingerprint_settings/#{@device.id}"
    reload_page('div_fingerprint','show', "fingerprint_settings/#{@device.id}")
  end

  def update
    if @device and @device.update_attributes(params[:fingerprint_device])
      flash.now[:notice] = "Data alat sidik jari berhasil diupdate"
      reload_page('div_fingerprint','show', "fingerprint_settings/#{@device.id}")
    else
      flash.now[:notice] = "Data alat sidik jari tidak berhasil diupdate"
      reload_page('div_fingerprint','edit')
    end
  end

  def delete_multiple
    flash.now[:notice] = "Data alat sidik jari gagal dihapus!"
    unless params[:ids].blank?
      a = FingerprintDevice.all(:conditions => "id in ('#{params[:ids].join("','")}') AND company_id = #{current_company_id}")
      a.each do |f|
        f.destroy
      end
      flash.now[:notice] = "Data alat sidik jari berhasil dihapus"
    end
    @devices = FingerprintDevice.all(:conditions => ['company_id = ?', current_company_id]).paginate({:page => params[:page], :per_page => 10})
    reload_page('div_fingerprint','index','fingerprint_settings')
  end

  def delete_device_data
    @devices = FingerprintDevice.all(:conditions => ['company_id = ?', current_company_id]).paginate({:page => params[:page], :per_page => 10})    
    if @device
      if @device.save_clear_data
        flash.now[:notice] = "Data kehadiran internal alat sidik jari berhasil dihapus!"
      else
        flash.now[:notice] = "Data kehadiran internal alat sidik jari gagal dihapus!"
      end
    else
      flash.now[:notice] = "Anda tidak berhak mengakses data ini!"      
    end
    reload_page('div_fingerprint','index','fingerprint_settings')
  end

  def device_presence
    @device = FingerprintDevice.find_by_ip_address(params[:device_ip])
    host = "#{@device.ip_address}"
    if @device.port
      host = [host, "#{@device.port}"].join(":")
    end
    @response = FingerprintDevice.read_device(host)
  end

  protected
  
  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name, :object => @fingerprint_settings          
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')"  unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def which_device
    @device = FingerprintDevice.find(:first, :conditions => [ "id = ? AND company_id = ?", params[:id], current_company_id])
  end

end

