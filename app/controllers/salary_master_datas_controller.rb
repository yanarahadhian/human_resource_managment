class SalaryMasterDatasController < ApplicationController
  add_breadcrumb "Gaji Dan Tunjangan", "#salaries"
  layout "application2"
  ssl_required :import, :download_salary

  before_filter :prepare_edit, :only => :edit
  before_filter :prepare_new, :only => :new
  
  def index
    add_breadcrumb "Data Master Gaji", "#salary_master_datas"
    session[:url_act] = "salary_master_datas"
    @data_master = SalaryMasterData.new
    prepare_index
    session[:import] = nil
    reload_page("master-data", "list_salary_master_datas", "salary_master_datas", "filter")
  end

  def edit
    @data_master_salary = SalaryMasterData.find_and_make_sure_user_has_access(params[:id], current_company_id)
    render :layout => false
  end

  def new
    add_breadcrumb "Data Master Gaji", "#salary_master_datas"
    add_breadcrumb "Tambah Master Gaji", "#salary_master_new"
    @data_master_salary = SalaryMasterData.new
    respond_to do |format|
      format.html { render :layout => false }
      format.js
    end
  end

  def create
    unless params[:person].blank?
      nik = params[:person].split(",")[1].strip
      person = Person.find_by_employee_identification_number(nik)
      @data_master_salary = SalaryMasterData.first(:conditions => "person_id=#{person.id} AND company_id=#{current_company_id}")
      premiums = Premium.all(:conditions => "company_id=#{current_company_id}", :order => "premium_name")

      if @data_master_salary.blank?
        @data_master_salary = SalaryMasterData.new(:basic_salary => params[:salary_master_data][:basic_salary],
                                                  :cooperation_cut => params[:salary_master_data][:cooperation_cut],
                                                  :valid_from => params[:salary_master_data][:valid_from],
                                                  :company_id => current_company_id,
                                                  :person_id => person.id)

        if @data_master_salary.save
          premiums.each do |x|
            @data_master_salary.premium_master_datas.new(:premiums_in_company_id => x.id,
                                                        :value => params[:salary_master_data][:new_premium_master_data]["#{x.id}"]).save unless params[:salary_master_data][:new_premium_master_data]["#{x.id}"].blank?
          end
          SalaryMasterData.create_history(@data_master_salary)
          flash[:notice] = "Master gaji berhasil ditambahkan"
          @data_master = SalaryMasterData.new
          prepare_index
          reload_page("div_index", "index", 'salary_master_datas')
        else
          flash[:notice] = "Master gaji tidak berhasil ditambahkan"
          prepare_new
          reload_page("div_index", 'new')
        end
      else
        @data_master_salary = SalaryMasterData.new
        prepare_new
        flash[:notice] = "Data master sudah ada sebelumnya"
        reload_page("div_index", 'new')
      end
    else
      @data_master_salary = SalaryMasterData.new
      prepare_new
      flash[:notice] = "Nama Karyawan tidak boleh kosong"
      reload_page("div_index", 'new')
    end
  end

  def update    
    @data_master_salary = SalaryMasterData.find_and_make_sure_user_has_access(params[:id], current_company_id)
    if is_valid_date?
      salary_master_data =  SalaryMasterData.rebuild_master_data(params[:salary_master_data])      
      if @data_master_salary.update_attributes(salary_master_data)
        unless @data_master_salary.employment_id.blank?
          emp = Employment.find(@data_master_salary.employment_id)
          @data_master_salary.update_attributes(:person_id => emp.person_id)
        end
        SalaryMasterData.create_new_history(@data_master_salary)
        flash.now[:notice] = "Master gaji berhasil diupdate"
        @data_master = SalaryMasterData.new
        prepare_index
        reload_page("div_index", "index", 'salary_master_datas')
      else
        flash.now[:notice] = "Master gaji gagal diupdate"
        prepare_edit
        reload_page("div_index","edit")
      end
    else
      flash.now[:notice] = "Tanggal berlaku tidak valid"
      prepare_edit
      reload_page("div_index","edit")
    end
  end

  def destroy
    flash.now[:notice] = "Master gaji gagal dihapus!"
    unless params[:ids].blank?
      id = params[:ids].join(",")
      salary = SalaryMasterData.all(:conditions => "company_id=#{current_company_id} and id in (#{id})")
      salary.each do |p|
        p.destroy
      end
      flash.now[:notice] = "Master gaji berhasil dihapus"
    end
    @data_master = SalaryMasterData.new
    prepare_index    
    reload_page("div_index","index")
  end

  def import
    flash[:notice] = "Data gaji gagal diimport"
    unless params[:salary_master_data].blank?
      @import = Import.new(params[:salary_master_data].merge(:company_id => current_company_id))
      if @import.save
        str_callback = @import.import_to_db2
        flash[:notice] = str_callback
      end
    end
    redirect_to "#{ApplicationController::BASE_URL}/a/#{current_permalink}#salary_master_datas"
  end

  def download_salary
    premiums = Premium.all(:conditions => "company_id=#{current_company_id}", :order => "premium_name")
    header = ["NIK","Nama_Depan","Nama_Belakang","Berlaku_Mulai","Gaji_Pokok","Potongan_Koperasi"] + premiums.collect{|x| x.premium_name}
    data_gaji = [
      ["1","Karyawan1","satu","01/01/2011","2300000","90000"]+SalaryMasterData.set_download_premium_data(premiums),
      ["2","Karyawan2","dua","01/01/2011","1500000","50000"]+SalaryMasterData.set_download_premium_data(premiums),
      ["3","Karyawan3","tiga","01/01/2011","2000000","60000"]+SalaryMasterData.set_download_premium_data(premiums),
      ["4","Karyawan4","empat","01/01/2011","1100000","30000"]+SalaryMasterData.set_download_premium_data(premiums)
      ]
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'master_gaji'
    sheet1.name = 'My First Worksheet'
    sheet1.row(0).concat header
    format = Spreadsheet::Format.new :weight => :bold, :size => 10
    sheet1.row(0).default_format = format
    data_gaji.each_with_index do |dt, index|
      arr_data = []
      dt.each do |x|
        arr_data << x
      end
      sheet1.row(index+1).concat arr_data
    end
    require 'stringio'
    data = StringIO.new ''
    book.write data
    file_name = "data_master_gaji.xls"
    send_data(data.string, :type=>"application/excel", :disposition=>'attachment',:filename => file_name)
  end

  def history
    @premiums = Premium.all(:conditions => ["company_id=?", current_company_id], :order => "premium_name")

    @history = SalaryMasterDataHistory.all(:conditions => ["salary_master_data_id=? and company_id=?", params[:id], current_company_id] )

    render :layout => false
  end

private

 def is_valid_date?
   is_valid = false
   @valid_from = params[:salary_master_data][:valid_from] unless params[:salary_master_data][:valid_from].blank?
   @basic_salary = params[:salary_master_data][:basic_salary] unless params[:salary_master_data][:basic_salary].blank?
   valid_from = @data_master_salary.valid_from
   valid_from = @data_master_salary.created_at if valid_from.blank?
   if valid_from < SalaryMasterData.date_split(@valid_from).to_date
      is_valid = true
   end unless @valid_from.blank?
   return is_valid
 end

 def prepare_edit   
   @premiums = Premium.all(:conditions => "company_id=#{current_company_id}", :order => "premium_name")
   @people = Person.by_company(current_company_id)
 end

 def prepare_new
   @premiums = Premium.all(:conditions => "company_id=#{current_company_id}", :order => "premium_name")
 end

 def prepare_index
   @per_page = 50
   condition = get_condition
   @data_master_salaries = SalaryMasterData.paginate(:page => params[:page],:include => :person, :per_page => @per_page, :conditions => condition)
   @premiums = Premium.all(:conditions => "company_id=#{current_company_id}", :order => "premium_name")
 end

 def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name, :object => @people
          page << "stop_filter()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end

  private

  def get_condition
   first_kond = Person.without_keluar_masuk + "AND people.company_id=#{current_company_id}"
   kond = ""
   unless params[:filter].blank?
     kond << Honor.find_by_filter(params[:filter],first_kond)
     kond << " AND " unless kond.blank?
   else
     person = Person.all(:select => "person.id",:include=> [:employments], :conditions => first_kond)
     person_id = person.collect{|x| x.id}
     kond << "person_id in (#{person_id.join(",")}) AND "
   end
   kond << "salary_master_datas.company_id=#{current_company_id}"
   return kond
 end
end
