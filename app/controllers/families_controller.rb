class FamiliesController < ApplicationController
  #before_filter :login_required
  before_filter :relationship_to_person_values, :except => [:destroy]
  ssl_required :print_card, :edit_health, :edit_emergency_contact, :update_emergency_contact, :delete_multiple, :popup_add_family,
  :popup_edit_family, :cancel_popup_detail
  def index
    @person = Person.find(params[:person_id])
    @families = @person.families
    render :layout=> false
  end

  def create
    @person = Person.find(params[:person_id])
    param = Family.params_to_date(params[:family])
    param.update(:relationship_to_person => param[:hubungan_lain]) if param[:relationship_to_person] == "Lain"
    @family = Family.new(param.merge({:person_id => params[:person_id]}))
    @address = @family.address
    get_state
    get_city
    if @family.save      
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#people/#{@person.id}?tab=2&save=create_family';</script></body></html>"
    else      
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      render :layout=> false, :action => :popup_add_family
    end
  end
  
  def update
    @person = Person.find(params[:person_id])
    city = get_city_by_param(params)
    params[:family][:address_attributes].update(:city=> city)
    param = Family.params_to_date(params[:family])
    @family = Family.find(params[:id])
    @address = Address.new(param[:address])
    get_state
    get_city

    if @family.update_attributes(param)      
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#people/#{@person.id}?tab=2&save=update_family';</script></body></html>"
    else
      @address = Address.new
      @addresses = @person.addresses
      @families = @person.families
      @sign = "gagal"
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      render :layout=> false, :action => :popup_edit_family
    end
  end


  def edit
    @person = Person.by_company(session[:platform_user]['user']['user_company']['id']).find(params[:id])
    @address = Address.new
    @addresses = @person.addresses
    @families = @person.families   
    get_state
    get_city
    render :layout => "application"
  end

  def destroy
    @person = Person.find(params[:id])
    if @person.destroy
      flash.now[:notice] = "Karyawan berhasil dihapus!"
      redirect_to people_path
    else
      flash.now[:notice] = "Karyawan tidak berhasil dihapus!"
      redirect_to people_path
    end
  end

  def print_card
    person = Person.find(params[:id])
    @company = person.holding_company.name
    render :layout => "/people/print_card.html.erb"
  end

  def edit_health
    @person = Person.find(params[:id])
    render :layout => "layouts/application.html.erb"
  end

  def edit_emergency_contact
    @person = Person.find(params[:id])
    render :layout => "application2"
  end

  def update_emergency_contact
   @person = Person.find(params[:id])
   if @person.update_attributes(params[:person])
      flash.now[:notice] = "Karyawan berhasil diubah!"
      redirect_to person_path(@person) + '?tab=4'
    else
      @thm = Person.find(params[:id])
      flash.now[:notice] = "Karyawan tidak berhasil diubah!"
      render :action => :edit
    end
  end

  def delete_multiple
    flash.now[:notice] = "Data keluarga gagal dihapus!"
    unless params[:ids].blank?
      @family = Family.find(params[:ids])
      @family.each do |family|
        family.destroy
      end
      flash.now[:notice] = "Data keluarga berhasil dihapus!"
    end
    @person = Person.find(params[:person_id])
    @families = @person.families
    reload_page('data_keluarga','families/list_families',"people/#{params[:person_id]}?tab=5")
  end

  def popup_add_family
    @person = Person.find(params[:person_id])
    @family = Family.new
    @family.address = Address.new
    @address = @family.address
    get_state
    get_city
    render :layout => false
  end

  def popup_edit_family    
    @person = Person.find(params[:person_id])
    @family = Family.find(params[:id])
    @address = @family.address
    get_state
    get_city
    render :layout => false
  end

  def cancel_popup_detail
    @person = Person.find(params[:person_id])
    @family = Family.find(params[:id])
    @address = @family.address
    get_state
    get_city
    reload_page("div_edit_family_form", "edit_form")
  end

  private

  def get_city_by_param(params)
    city = ""
    unless params[:address].blank?
      city = params[:address][:city] unless params[:address][:city].blank?
    end
    unless params[:family][:address_attributes][:city].blank?
      city = params[:family][:address_attributes][:city]
    end
    return city
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

  def relationship_to_person_values
    @city = Family.find(:all, :select => "distinct city_of_birth").collect{|rel| rel.city_of_birth}.join(',')
    @education = Family.find(:all, :select => "distinct highest_education").map{|m| m.highest_education}.join(',')
    @relation = Family.find(:all, :select => "distinct relationship_to_person").map{|m| m.relationship_to_person}.join(',')
  end

  def reload_page(div_name, page_name, url = nil)
    respond_to do |format|
        format.html {}
        format.js {
          render :update do |page|
            page.replace_html div_name, :partial=> page_name, :object => @people
            page << "$.address.value('#{url}');" unless url.blank?
            page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
            page << "removeNotifyMessage();"
          end
        }
      end
  end
end
