class ExperiencesController < ApplicationController
  #before_filter :login_required
  ssl_required :ajax_experience_company_name, :popup_edit_experience, :cancel_popup_detail, :popup_add_experience, :delete_multiple
  def index
    @person = Person.find(params[:person_id])
  end
  
  def new
    @type = params[:experience_type]    
    @experience = Experience.new
    @experience.experience_type = @type
    @opened_tab = opened_tab(@type)
  end

  def create
    @previus_company = PreviousCompany.find_by_company_name(params[:experience][:company_name])
    if @previus_company.blank?
      @previus_company = PreviousCompany.new(:company_name => params[:experience][:company_name])
      @previus_company.save
    end
    @person = Person.find(params[:person_id])
    @experience = Experience.new(params[:experience].merge({:person_id => params[:person_id], :previous_company_id=>@previus_company.id}))
    @data_type = params[:experience][:data_type]
    @opened_tab = opened_tab(@data_type)
    if @experience.save
      flash.now[:notice] = "Riwayat #{opened_sign_sukses(@data_type)} berhasil ditambah!"
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#history/#{@person.id}?tab=#{@opened_tab}&save=create_experience';</script></body></html>"
    else
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      render :layout=> false, :action => :popup_add_experience
    end
  end

  def edit
    @experience = Experience.find(params[:id])
    @type = @experience.experience_type
    @opened_tab = opened_tab(@type)
  end

  def update    
    @person = Person.find(params[:person_id])
    @experience = Experience.find(params[:id])
    @data_type = params[:experience][:data_type]
    #if is_approved(params[:username], params[:password]) && @experience.update_attributes(params[:experience])
    if @experience.update_attributes(params[:experience])
      flash.now[:notice] = "Riwayat berhasil diubah!"
      render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.href='#{current_root_url}#history/#{@person.id}?tab=#{opened_tab(@data_type)}&save=update_experience';</script></body></html>"
    else
      @sign = "gagal"
      render :layout=> false, :action => :popup_edit_experience
    end
  end

  def destroy
    @experience = Experience.find(params[:id])
    @type = @experience.experience_type
    if @experience.destroy
      flash.now[:notice] = "Experience berhasil dihapus!"
      redirect_to history_path(params[:person_id])+'?tab='+opened_tab(@type)
    end
  end

  def ajax_experience_company_name
    company = Company.find(:all, :conditions => ['company_name LIKE ? OR company_name LIKE ? OR
      company_name LIKE ? ', params[:q]+'%', '%'+params[:q]+'%', '%'+params[:q]])
      data = company.map { |c| "#{c.company_name}|#{c.id}" }.join("\n")
      data += "\nTidak ada perusahaan yang sesuai, saya mau input baru|0"
    render :text => data
  end


  def popup_edit_experience
    @data_type = params[:data_type]
    @person = Person.find(params[:person_id])
    @experience = Experience.find(params[:id])
    render :layout => false
  end

  def cancel_popup_detail
    @data_type = params[:data_type]
    @person = Person.find(params[:person_id])
    @experience = Experience.find(params[:id])
    reload_page("div_edit_experience_form", "edit_form")
  end

  def popup_add_experience
    @data_type = params[:data_type]
    @person = Person.find(params[:person_id])
    @experience = Experience.new
    render :layout => false
  end

  def delete_multiple
    @opened_tab = '2'
    flash.now[:notice] = "Data gagal dihapus!"
    unless params[:ids].blank?
      @experience = Experience.find(params[:ids])
      @experience.each do |experience|
        experience.destroy
      end      
      @type  = @experience.first.experience_type
      @opened_tab = opened_tab(@type)
      flash.now[:notice] = "Data riwayat #{opened_sign_sukses(@type)} berhasil dihapus"
    end
    @person = Person.find(params[:person_id])
    @experiences = @person.experiences
    if @opened_tab == '2'
      reload_page('riwayat_pekerjaan','people/riwayat_pekerjaan',"history/#{@person.id}?tab=#{@opened_tab}")
    else
      reload_page('riwayat_organisasi','people/riwayat_organisasi',"history/#{@person.id}?tab=#{@opened_tab}")
    end
  end

  private

  def opened_tab(text)
    case text
      when 'work'
        '2'
      when 'organizational'
        '3'
      when 'training'
        '4'
    end
  end

  def opened_sign_sukses(text)
    case text
      when 'work'
        'pekerjaan'
      when 'organizational'
        'organsisasi'
      when 'training'
        '4'
    end
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


