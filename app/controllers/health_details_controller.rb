class HealthDetailsController < ApplicationController
  ssl_required
  def index
  end

  def new
    @health_detail = HealthDetail.new
    render :layout => "application2.html"
  end

  def edit
    @health_detail = HealthDetail.find(params[:id])
    render :layout => "application2.html"
  end

  def update
     @health_detail = HealthDetail.find(params[:id])
    #if is_approved(params[:username], params[:password]) && @family.update_attributes(params[:family])
    if @health_detail.update_attributes(params[:health_detail])
      flash.now[:notice] = "Riwayat penyakit berhasil diubah !"
      redirect_to person_path(params[:person_id]) + '?tab=3'
    else
      flash.now[:notice] = "Riwayat penyakit berhasil diubah !"
      render :action => :edit
    end
  end

  def create
    @health_detail = HealthDetail.new(params[:health_detail].merge({:health_id=>params[:health_id]}))
    if @health_detail.save
      flash.now[:notice] = "riwayat penyakit berhasil ditambah !"
      redirect_to person_path(params[:person_id]) + '?tab=3'
    else
      flash.now[:notice] = "riwayat penyakit tidak berhasil ditambah !"
      render :action => :new
    end
  end
end