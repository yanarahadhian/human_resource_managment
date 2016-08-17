class EducationsController < ApplicationController
  #before_filter :login_required
  before_filter :data_companies, :except => [:destroy]
  
  ssl_required :popup_add_pendidikan, :cancel_popup_detail, :popup_edit_pendidikan, :delete_multiple

  def index
    @educations = Education.find(:all)
  end
  
  def new
    @education = Education.new
  end

  def create
    @person = Person.find(params[:person_id])
    @education = Education.new(params[:education].merge({:person_id => params[:person_id]}))
    if @education.save
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#history/#{@person.id}?tab=0&save=create_education';</script></body></html>"
    else      
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      render :layout=> false, :action => :popup_add_pendidikan
    end
  end

  def edit
    @education = Education.find(params[:id])
    @thm = @education
  end

  def update
    @person = Person.find(params[:person_id])
    @education = Education.find(params[:id])
    if @education.update_attributes(params[:education])
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#history/#{@person.id}?tab=0&save=update_education';</script></body></html>"
    else
      @thm= Education.find(params[:id])
      @sign="gagal"
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      render :layout=> false, :action => :popup_edit_pendidikan
    end
  end

  def popup_add_pendidikan
     @person = Person.find(params[:person_id])
     @education = Education.new
     render :layout => false
  end


  def cancel_popup_detail
    @person = Person.find(params[:person_id])
     @education = Education.find(params[:id])
     @thm = @education
    reload_page("div_edit_education_form", "edit_form")
  end

  def popup_edit_pendidikan
     @person = Person.find(params[:person_id])
     @education = Education.find(params[:id])
     @thm = @education
     render :layout => false
  end

  def delete_multiple
    flash.now[:notice] = "Data riwayat pendidikan gagal dihapus!"
    unless params[:ids].blank?
      @education = Education.find(params[:ids])
      @education.each do |education|
        education.destroy
      end
      flash.now[:notice] = "Data riwayat pendidikan berhasil dihapus"
    end
    @person = Person.find(params[:person_id])
    reload_page('riwayat_pendidikan',"people/riwayat_pendidikan","history/#{@person.id}?tab=0")
  end


  private

  def data_companies
    @companies = PreviousCompany.all
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
