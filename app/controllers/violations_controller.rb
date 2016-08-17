class ViolationsController < ApplicationController
  #before_filter :login_required
  ssl_required :delete_multiple, :ajax_violation_person_in_charge_name
  def index
    @person = Person.find(params[:person_id])
    @employments = @person.employments
    @violations = @person.violations.find(:all, :order => 'occurence_date DESC, active_until DESC')
  end
  
  def new
    @person = Person.find(params[:person_id])
    @violation = @person.violations.new
  end

  def create
    param = Violation.params_to_date(params[:violation])    
    @violation = Violation.new(param.merge({:person_id => params[:person_id]}))
    if @violation.save
      flash.now[:notice] = "Pelanggaran berhasil ditambah !"
      #reload_page('div_new_sp','employments/index',"people/#{params[:violation][:pers_id]}/employments?tab=3")
      redirect_to person_employments_path(params[:person_id]) + '?tab=3'
    else
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      render :action => :new
    end
  end

  def edit
    @person = Person.find(params[:person_id])
    @violation = Violation.find(params[:id])
    render :layout => false
  end

  def update
    @violation = Violation.find(params[:id])
    param = Violation.params_to_date(params[:violation])
    #if is_approved(params[:username], params[:password]) && @violation.update_attributes(params[:violation])
    if @violation.update_attributes(param)
      flash.now[:notice] = "Pelanggaran berhasil diubah !"
      redirect_to person_employments_path(params[:person_id]) + '?tab=3'
    else
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      render :action => :edit
    end
  end

  def delete_multiple
    unless params[:ids].blank?
      @violation = Violation.find(params[:ids])
      @violation.each do |violation|
        violation.destroy
      end
      flash.now[:notice] = "Data pelanggaran berhasil dihapus!"
    end
    @person = Person.find(params[:person_id])
    @violations = @person.violations.find(:all, :order => 'occurence_date DESC, active_until DESC')
    reload_page('info_pelanggaran','violations/list_violations',"people/#{params[:person_id]}/employments?tab=3")
  end

  def destroy
    @violation = Violation.find(params[:id])
    if @violation.destroy
      flash.now[:notice] = "Pelanggaran berhasil dihapus !"
    else
      flash.now[:notice] = "Pelanggaran tidak berhasil dihapus !"
    end
    redirect_to person_employments_path(params[:person_id]) + '?tab=3'
  end

  def ajax_violation_person_in_charge_name
    people = Person.find(:all, :conditions => ['( full_name LIKE ? OR full_name LIKE ? OR
      full_name LIKE ? ) AND id <> ?', params[:q]+'%', '%'+params[:q]+'%', '%'+params[:q], params[:id]])
    render :text => proc { |response, output| people.each do |person| output.write("#{person.full_name}|#{person.id}\n") end }
  end

private

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
        format.html { render :layout => false }
        format.js {
          render :update do |page|
            page.replace_html div_name, :partial=> page_name
            page << "stop_filter()" unless stop_filter.blank?
            page << "$.address.value('#{url}');" unless url.blank?
            page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
            page << "removeNotifyMessage();"
          end
        }
      end
  end
end
