class AccidentsController < ApplicationController
  before_filter :prepare_autocomplete_data, :only=> ["new", "create", "edit", "update"]
  #before_filter :login_required
  ssl_required :delete_multiple, :ajax_accident_location_name, :ajax_accident_category_name
  
  # GET /accidents
  # GET /accidents.xml
  layout 'application'

  def index
    person = Person.find(params[:person_id])
    @accidents = Accident.by_company(current_company_id).find(:all, :conditions=>{:person_id=>[person.id]}, :order => 'accident_date DESC') # person.accidents

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accidents }
    end
  end

  # GET /accidents/new
  # GET /accidents/new.xml
  def new
    @accident = Accident.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @accident }
    end
  end

  # GET /accidents/1/edit
  def edit    
     @accident = Accident.find(params[:id])
  end

  # POST /accidents
  # POST /accidents.xml
  def create
    param = Accident.param_date_to_str(params[:accident])
    person = Person.find(params[:person_id])
    @accident = person.accidents.build(param)

    if @accident.save
      #format.html { redirect_to(person_accidents_path, :notice => 'Kecelakaan berhasil ditambah.') }
      flash.now[:notice] = "Kecelakaan berhasil ditambah !"
      redirect_to person_employments_path(params[:person_id])+'?tab=4'
      #format.html { redirect_to :action=>"index", :id => params[:person_id] }
      #format.xml  { render :xml => @accident, :status => :created, :location => @accident }
    else
      respond_to do |format|
        flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
        format.html { render :action => "new"}
        format.xml  { render :xml => @accident.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accidents/1
  # PUT /accidents/1.xml
  def update
    param = Accident.param_date_to_str(params[:accident])
    @accident = Accident.find(params[:id])

    #if is_approved(params[:username], params[:password]) && @accident.update_attributes(params[:accident])
    if @accident.update_attributes(param)
      flash.now[:notice] = "Kecelakaan berhasil diubah !"
      #format.html { redirect_to :action => "index", :id => params[:person_id] }
      redirect_to person_employments_path(params[:person_id])+'?tab=4'
      #format.xml  { head :ok }
    else
      respond_to do |format|
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      format.html { render :action => "edit" }
      format.xml  { render :xml => @accident.errors, :status => :unprocessable_entity }
    end
   end
  end

  # DELETE /accidents/1
  # DELETE /accidents/1.xml
  def destroy
    @accident = Accident.find(params[:id])
    @accident.destroy
    if @accident.destroy
      flash.now[:notice] = "Kecelakaan berhasil dihapus !"
      redirect_to person_path(params[:person_id])+'?tab=5'
      #format.html { redirect_to :action => "index", :id => params[:person_id] }
      #format.xml  { head :ok }
    else
      respond_to do |format|
        flash.now[:notice] = "Kecelakaan tidak berhasil dihapus !"
        format.html { render :action => "index", :id => params[:person_id] }
        format.xml  { render :xml => @accident.errors, :status => :unprocessable_entity }
      end
    end
  end

   def delete_multiple
    unless params[:ids].blank?
      @accident = Accident.find(params[:ids])
      @accident.each do |accident|
        accident.destroy
      end
      flash.now[:notice] = "Data kecelakaan berhasil dihapus!"
    end
    @person = Person.find(params[:person_id])
    @accidents = Accident.by_company(current_company_id).find(:all, :conditions=>{:person_id=>[@person.id]}, :order => 'accident_date DESC')
    reload_page('info_kecelakaan','accidents/list_accidents',"people/#{@person.id}?tab=4")
  end

  def ajax_accident_location_name
    ajax_lists "accident_location"
  end

  def ajax_accident_category_name
    ajax_lists "accident_category"
  end

private

  def ajax_lists(attribute)
    accidents = Accident.all(:conditions => ["#{attribute} LIKE ? OR #{attribute} LIKE ? OR #{attribute} LIKE ?", params[:q]+'%', '%'+params[:q]+'%', '%'+params[:q]])
    render :text => proc { |response, output| accidents.each do |acc| output.write("#{acc.send(attribute)}|#{acc.id}\n") end }
  end

  def prepare_autocomplete_data
    @locations = Accident.find(:all, :select => 'DISTINCT accident_location').map{|m| m.accident_location}.join(',')
  end

  def reload_page(div_name, page_name, url = nil)
    respond_to do |format|
      format.html {}
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name
          page << "$.address.value('#{url}');"
          page << "removeNotifyMessage();"
        end
        }
      end
  end
  
end
 
