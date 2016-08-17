class AddressesController < ApplicationController
  before_filter :login_required
  before_filter :city_and_state_values, :except => [:destroy]
  ssl_required :popup_add_address, :popup_edit_address, :cancel_popup_detail, :change_city, :delete_multiple
  def index
    @person = Person.find(params[:person_id])
    render :layout=> false
  end

  def create
    @person = Person.find(params[:person_id])
    get_state
    get_city(params[:address][:state])
    @address = Address.new(params[:address])
    @address.owner = @person
    if @address.save
      prepare_show
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#people/#{@person.id}?tab=5&save=create_alamat';</script></body></html>"
    else
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      render :layout=> false, :action => :popup_add_address
    end
  end

  def update
    @person = Person.find(params[:person_id])
    @address = Address.find(params[:id])
    if @address.update_attributes(params[:address])
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#people/#{@person.id}?tab=5&save=update_alamat';</script></body></html>"
    else
      get_state
      get_city
      @sign = "gagal"
      render :layout=> false, :action => :popup_edit_address
    end
  end

  def popup_add_address
    @person = Person.find(params[:person_id])
    @address = Address.new
    get_state
    get_city
    render :layout => false
  end

  def popup_edit_address
    @address = Address.find(params[:id])
    get_state
    get_city(@address.state)
    render :layout => false
  end

  def cancel_popup_detail
    @address = Address.find(params[:id])
    get_state
    get_city
    reload_page("div_edit_address_form", "edit_form")
  end

  def change_city    
    province_name = ""    
    province_name = params[:province_name] unless params[:province_name].blank?    
    get_city(province_name)
    render :update do |page|
      page.replace_html "div_city", :partial=> "addresses/city", 
        :locals=> {:sign => params[:sign], :province_name => params[:province_name]}
    end
  end

  def delete_multiple
    flash.now[:notice] = "Alamat gagal dihapus!"
    unless params[:ids].blank?
      @address = Address.find(params[:ids])
      @address.each do |address|
        address.destroy
      end
      flash.now[:notice] = "Alamat berhasil dihapus!"
    end
    @person = Person.find(params[:person_id])
    reload_page('info_alamat','addresses/list_people_address',"people/#{params[:person_id]}?tab=5")
  end

private

  def city_and_state_values
    @city = Address.find(:all, :select => "distinct city").map{|m| m.city}.join(',')
    @state = Address.find(:all, :select => "distinct state").map{|m| m.state}.join(',')
  end

  def get_state
    require 'net/https'
    url = URI.parse("#{ApplicationController::APPSCHEF_URL}/api/provinces")
    if RAILS_ENV == "development" && PROTOCOL_STRING != "https://"
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
    else
      req = Net::HTTP.new(url.host, url.port)
      req.use_ssl = true
      req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http = Net::HTTP::Get.new(url.request_uri)
      res = req.request(http)
    end
    @state = ActiveSupport::JSON.decode(res.body)
  end

  def get_city(province_name = nil)
    require "uri"
    require 'net/https'
    if RAILS_ENV == "development" && PROTOCOL_STRING != "https://"
      province_name = "" if province_name=="nil"
      params = {"province_name" => "#{province_name}" }
      url = URI.parse(URI.encode("#{ApplicationController::APPSCHEF_URL}/api/cities/list?province_name=#{province_name}"))
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data(params)
      res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
    else
      url = URI.parse(URI.encode("#{ApplicationController::APPSCHEF_URL}/api/cities/list?province_name=#{province_name}"))
      req = Net::HTTP.new(url.host, url.port)
      req.use_ssl = true
      req.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http = Net::HTTP::Get.new(url.request_uri)
      res = req.request(http)
    end
    @city = ActiveSupport::JSON.decode(res.body)
  end

   def prepare_show
    @import = Import.new
    @is_user_login = false
    unless current_user.person.blank?
      @is_user_login = params[:id].to_i == current_user.person.id && !params[:view_only].blank?
    end
    @experiences = @person.exp_by_type('work')
    @families = @person.families
    @accidents = Accident.find(:all, :conditions=>{:person_id=>[@person.id]}, :order => 'accident_date DESC') # person.accidents
    @awards = @person.awards
    @family = Family.new
    @family.address = Address.new
    @address = @family.address
  end

   def reload_page(div_name, page_name, url = nil)
    respond_to do |format|
        format.html {}
        format.js {
          render :update do |page|
            page.replace_html div_name, :partial=> page_name
            page << "$.address.value('#{url}');" unless url.blank?
            page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
            page << "removeNotifyMessage();"
          end
        }
      end
  end
end
