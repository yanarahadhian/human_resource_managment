class AwardsController < ApplicationController
  before_filter :login_required
  ssl_required :update_award, :create_award, :cancel_award, :destroy_award
  # GET /awards
  # GET /awards.xml
  def index
    @person = Person.find(params[:person_id])
    @award = Award.new
  end

  # GET /awards/1
  # GET /awards/1.xml
  def show
    @award = Award.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @award }
    end
  end

  # GET /awards/1/edit
  def edit
    @person = Person.find(params[:person_id])
    @award = Award.find(params[:id])
  end

  def update
    param = Award.param_date_to_str(params[:award])
    @award = Award.find(params[:id])
    if @award.update_attributes(param)
      flash.now[:notice] = "Penghargaan berhasil diubah!"
      redirect_to history_path(params[:person_id])+'?tab=4'
    else
      flash.now[:notice] = "Maaf, ada kesalahan atau kekurangan dalam penginputan. Mohon periksa kembali"
      render :action => :edit
    end
  end

  def update_award
    @award = Award.find(params[:id])
    @person = Person.find(params[:award][:person_id])
    if @award.update_attributes(params[:award])
      flash.now[:notice] = "Date penghargaan berhasil diupdate"
      reload_page("div_riwayat_penghargaan","people/riwayat_penghargaan")
    end
  end

  def create_award
    @person = Person.find(params[:award][:person_id])
    @award = Award.new(params[:award])
    if @award.save
      flash.now[:notice] = "Data penghargaan berhasil ditambahkan"
      reload_page("div_riwayat_penghargaan","people/riwayat_penghargaan")
    end
  end

  def cancel_award
    @person = Person.find(params[:person_id])
    @award = Award.find(params[:id])
    flash.now[:notice] = "Data penghargaan berhasil dihapus"
    reload_page("div_riwayat_penghargaan","people/riwayat_penghargaan")
  end

  def destroy_award
    @award = Award.find_by_id(params[:id])
    unless @award.blank?
      @award.destroy
      flash.now[:notice] = "Data penghargaan berhasil dihapus"
    end
    @award = Award.new
    @person = Person.find(params[:person_id])
    reload_page("div_riwayat_penghargaan","people/riwayat_penghargaan")
  end
end

private

def reload_page(div_name, render_name)
  render :update do |page|
    page.replace_html div_name, :partial => render_name
    page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
    page << "removeNotifyMessage();"
  end
end
