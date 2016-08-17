class PayrollsController < ApplicationController
  add_breadcrumb "Payroll", "#payrolls"
  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :create, :create_premium, :update_premium, :update_ptkp, :delete_premium]
  before_filter :prepare_payroll_setting, :only=> [:index, :new, :create]

  # Check features accessability by user roles
  def check_features
    case params[:action]
      when "index"
        current_features.include?('payroll_index') ? true : invalid_features
      when "edit"
        current_features.include?('payroll_edit') ? true : invalid_features
      when "create"
        current_features.include?('payroll_edit') ? true : invalid_features
      when "create_premium"
        current_features.include?('payroll_edit') ? true : invalid_features
      when "update_premium"
        current_features.include?('payroll_edit') ? true : invalid_features
      when "update_ptkp"
        current_features.include?('payroll_edit') ? true : invalid_features
      when "delete_premium"
        current_features.include?('payroll_edit') ? true : invalid_features
    end
    # return true
  end

  def index
    @row = @premiums.count
    @row_ptkp = @tax.count
    render :layout =>false
  end

  def new
    add_breadcrumb "Edit Payroll", "#payroll/new"
    @payroll = PayrollSetting.new(params['payroll_setting']) if @payroll.blank?
    render :layout => false
  end

  def create
    if @payroll.blank?
      @payroll = PayrollSetting.new(params[:payroll_setting])      
      @payroll.company_id = current_company_id
      @payroll.full_working_days = params[:full_working_days]
      if @payroll.save
        flash.now[:notice] = "Data payroll berhasil disimpan"
        reload_page("div_new","index_partial","payrolls")
      else
        flash.now[:notice] = "Mohon mengisi Data Yang Diperlukan Dengan Benar"
        reload_page("div_new","new_partial")
      end
    else
      @payroll.full_working_days = params[:full_working_days]
      @payroll.jamsostek_value = params[:payroll_setting][:jamsostek_value]
      @payroll.use_logo_in_payroll_slip = params[:payroll_setting][:use_logo_in_payroll_slip]
      if @payroll.update_attributes(params[:payroll_setting])
        # @payroll.jamsostek_value = params[:payroll_setting][:jamsostek_value]
        # @payroll.save
        flash.now[:notice] = "Data payroll berhasil diupdate"
        reload_page("div_new","index_partial","payrolls")
      end
    end
  end

  def premiums
    @premiums = Premium.all(:conditions => ['company_id = ?' , current_company_id])
    @row = @premiums.count
    render :layout => false
  end

  def create_premium
    @premium = Premium.new(
      :premium_name => params[:premium_name],
      :calculated_automatically => true,
      :calculated_on_overtime => params[:on_overtime],
      :calculated_on_salary_cut => params[:on_salary_cut],
      :count_daily => params[:count_daily])
      @premium.company_id = current_company_id
    if @premium.save
      @premiums = Premium.all(:conditions => ['company_id = ?' , current_company_id])
      flash.now[:notice] = "Data tunjangan berhasil disimpan"
      load_page("table_premium", "payrolls/premiums")
    else
      @premiums = Premium.all(:conditions => ['company_id = ?' , current_company_id])
      flash.now[:notice] = "Ada kesalahan dalam penginputan data sehingga data tunjangan tidak berhasil disimpan!"
      load_page("table_premium", "payrolls/premiums")
    end
  end

  def update_premium
    @premium = Premium.find(:first, :conditions => {:id => params[:premium_id], :company_id => current_company_id})
    if @premium and @premium.update_attributes(:premium_name => params[:premium_name],
      :calculated_automatically => params[:on_overtime],
      :calculated_on_overtime => params[:on_overtime],
      :calculated_on_salary_cut => params[:on_salary_cut],
      :count_daily => params[:count_daily])
      flash.now[:notice] = "Data tunjangan berhasil diupdate"
    else
      flash.now[:notice] = "Data tunjangan gagal diupdate"
    end
    @premiums = Premium.all(:conditions => ['company_id = ?' , current_company_id])
    load_page("table_premium", "payrolls/premiums")
  end

  def update_ptkp
    @premium = TaxStatus.find(:first, :conditions => {:id => params[:id], :company_id => current_company_id})
    if @premium.update_attributes(:ptkp => params[:ptkp_value])
      flash.now[:notice] = "Data PTKP berhasil diupdate"
    else
      flash.now[:notice] = "Data PTKP gagal diupdate"
    end
    @tax = TaxStatus.all(:conditions=> "company_id=#{current_company_id}")
    load_page("table_ptkp", "payrolls/ptkp")
  end

  def delete_premium
    @premium = Premium.find(:first, :conditions => {:id => params[:id], :company_id => current_company_id})
    if @premium.destroy
      flash.now[:notice] = "Data tunjangan berhasil dihapus"
    else
      flash.now[:notice] = "Data tunjangan gagal dihapus"
    end
    @premiums = Premium.all(:conditions => ['company_id = ?' , current_company_id])
    load_page("table_premium", "payrolls/premiums")
  end

  def premium_table
    unless params[:del] == "1"
      puts"unless"
      @premiums = Premium.new(:premium_name => params[:premium_name],
        :calculated_automatically => params[:calculated_automatically],
        :calculated_on_overtime => params[:calculated_on_overtime],
        :calculated_on_salary_cut => params[:calculated_on_salary_cut],
        :count_daily => params[:count_daily])
      @premium.company_id = current_company_id
      @premiums.save
      @premiums = Premium.all(:conditions => ['company_id = ?' , current_company_id])
       render :layout => false
    else
      puts"else"
      @premiums = Premium.first(:conditions => ['id = ?',params[:premium_id] ])
      @premiums.delete
      @premiums = Premium.all(:conditions => ['company_id = ?' , current_company_id])
       render :layout => false
    end
  end

  private

  def prepare_payroll_setting
    @payroll = PayrollSetting.find(:first , :conditions=>["company_id = ?" , current_company_id])
    @premiums = Premium.all(:conditions => ['company_id = ?' , current_company_id])
    @company_name =  current_company_name
    @tax = TaxStatus.all(:conditions => "company_id =#{current_company_id}")
  end

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name, :object => @payroll
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  def load_page(div_name, partial_name)
    render :update do |page|
      page.replace_html div_name, :partial => partial_name
      page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')"  unless flash.now[:notice].blank?
      page << "removeNotifyMessage();"
    end
  end

end

