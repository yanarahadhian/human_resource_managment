class HolidaysController < ApplicationController
  layout  "application_setting"

  ssl_required :check_features
  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :create, :edit, :update, :destroy]
  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('holiday_index') ? true : invalid_features
    when "new", "create"
      current_features.include?('holiday_new') ? true : invalid_features
    when "edit", "update"
      current_features.include?('holiday_edit') ? true : invalid_features
    when "destroy"
      current_features.include?('holiday_delete') ? true : invalid_features
    end
    # return true
  end

  def index
    add_breadcrumb "Hari Libur", "#holidays"
    unless params['filter'].blank?
      unless params["filter"]["date"] == ""
        params[:filter][:periode] = params["filter"]["date"]
      end
      @filtering = 1
    else
      @filtering = 0
    end
    prepare_index
    reload_page('the_list','holidays/list_holidays','holidays','filter')
  end

  def new
    add_breadcrumb "Hari Libur", "#holidays"
    add_breadcrumb "Tambah Hari Libur", "#holiday/new"
    @holiday = NationalHoliday.new
    render :layout => false
  end

  def edit
    @holidays = NationalHoliday.find(:first, :conditions => { :company_id => current_company_id, :id => params[:id] })
    if @holidays
      add_breadcrumb "Hari Libur", "#holidays"
      add_breadcrumb "Tambah Hari Libur", "#editHoliday/#{@holidays.id}"
      render :layout => false
    else
      render :nothing => true
    end
  end

  def update
    @holidays = NationalHoliday.find(:first, :conditions => { :company_id => current_company_id, :id => params[:id] })
    flash.now[:notice] = "Data gagal Diperbaharui"
    if @holidays and @holidays.update_attributes(params[:national_holiday])
      flash.now[:notice] = "Data hari libur berhasil diupdate"
      @filtering = 0
      prepare_index
      reload_page('div_index','index','holidays')
    else
      reload_page('div_index','edit')
    end
  end

  def create
    unless params[:holiday].blank?
      @holiday = NationalHoliday.new(params['holiday'])
      @holiday.company_id = current_company_id
      if @holiday.save
        flash.now[:notice] = "Data hari libur berhasil disimpan"
        @filtering = 0
        prepare_index
        reload_page('div_index','index','holidays')
      else
        flash.now[:notice] = "Mohon Mengisi Semua Data Yang Diperlukan"
        reload_page('div_index','new')
      end
    end
  end

  def delete_multiple
    flash.now[:notice] = "Data hari libur gagal dihapus"
    unless params[:ids].blank?
      id = params[:ids]
      hol = NationalHoliday.all(:conditions => "id in ('#{id.join("','")}') and company_id = #{current_company_id}")
      hol.each do |f|
        f.destroy
      end
      flash.now[:notice] = "Data hari libur berhasil dihapus"
    end
    prepare_index
    reload_page('div_index','index')
  end

private

  def prepare_index
    @per_page = 10
    holidays = NationalHoliday.search_filter(params[:filter], current_company_id)
    @holidays = holidays.paginate({:page => params[:page], :per_page => 10})
    @count = holidays.count
  end

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name, :object => @holidays
          page << "parent.$.fn.colorbox.close();" if params[:action]=="destroy"
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end
end

