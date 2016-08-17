class HolidayAllowancesController < ApplicationController
  add_breadcrumb "Gaji Dan Tunjangan", "#salaries"
  before_filter :login_required
  before_filter :determine_date, :only => [:index]
  before_filter :prepare_new, :only => [:new]
  before_filter :prepare_index, :only => [:index]
  
  layout "application2"
  
  ssl_required :check_features, :reset_list_thr, :download, :export, :export_to_xls, :generate_payroll, :mine
  before_filter :current_features
  before_filter :check_features, :only => [:index, :new, :edit, :destroy, :show, :export]
  # Check features accessability by user roles
  def check_features
    case params[:action]
    when "index"
      current_features.include?('thr_index') ? true : invalid_features
    when "new"
      current_features.include?('thr_new') ? true : invalid_features
    when "edit"
      current_features.include?('thr_edit') ? true : invalid_features
    when "destroy"
      current_features.include?('thr_delete') ? true : invalid_features
    when "show"
      current_features.include?('thr_detail') ? true : invalid_features
    # when "export"
      # current_features.include?('thr_export') ? true : invalid_features
    end
    # return true
  end

  def index
    session[:url_act] = "holiday_allowances"
    add_breadcrumb "THR", "#holiday_allowances"
    reload_page("div_index", 'index', nil, "filter")
  end

  def show
    @id = params[:id]
    @thr = Honor.find_and_make_sure_user_has_access(@id, current_company_id)
    @honor_month = Date::MONTHNAMES[@thr.honor_month]
    @last_honor = Honor.find(:last, :conditions => [" is_thr = 0  and person_id = ?", @thr.person_id])
    @last_honor = Honor.new if @last_honor.blank?
    render :layout => false
  end

  def destroy
    flash.now[:notice] = "THR Gagal dihapus!"
    unless params[:ids].blank?
      honor= Honor.find(params[:ids])
      honor.each do |p|
        if p.company_id == current_company_id
          p.destroy
        end
      end
      flash.now[:notice] = "THR berhasil dihapus!"
    end
    @is_destroy = true
    determine_date
    prepare_index
    reload_page('honors','list_thr')
  end

  def edit
    @honor = Honor.find_and_make_sure_user_has_access(params[:id], current_company_id)
    @person = @honor.person

    @honor_month = @honor.honor_date.month
    @honor_year = @honor.honor_date.year
    @filter_date = @honor.honor_date

    # Get all premiums on his/her company
    @premiums_in_companies = PremiumsInCompany.find(:all, :conditions => "company_id = #{current_company_id}")
    render :layout => false
  end
  def update
    @honor = Honor.find_and_make_sure_user_has_access(params[:id], current_company_id)
    @last_honor = Honor.find(:last, :conditions => [" is_thr = 0  and person_id = ?", @honor.person_id])
    if @honor.update_attributes(params['honor'])
      unless @honor.file_name.blank?
        last_file = File.exist?("#{RAILS_ROOT}/thrs/#{@honor.honor_date.year}/#{@honor.honor_date.month}/#{@honor.file_name}")
      end

      if last_file
        File.delete("#{RAILS_ROOT}/thrs/#{@honor.honor_date.year}/#{@honor.honor_date.month}/#{@honor.file_name}")
        generate_thr_receipt
      end

      flash.now[:notice] = "Data berhasil diupdate"
      after_update_data
    else
      flash.now[:notice] = "Data gagal diupdate"
      reload_page("honor-details", 'thr_details')
    end
  end

  def new
    add_breadcrumb "THR", "#holiday_allowances"
    add_breadcrumb "Hitung Thr", "#new_holiday_allowance"
    @premiums = Premium.all
    unless params[:date].blank?
      @honor_month = params[:date][:month]
      @honor_year = params[:date][:year]
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.js
    end
  end

  def create
    @honor = Honor.new(params[:honor])
    @honor.person_id = params[:honor][:person_id]
    @honor.is_thr = true
    @honor.company_id = current_company_id
    @honor_month = params[:honor][:honor_month]
    @honor_year = params[:honor][:honor_year]
    @person = Person.find(params[:honor][:person_id]) unless params[:honor][:person_id].blank?
    if @person.more_than_three_months && @honor.save
      flash.now[:notice] = "Data berhasil disimpan"
      after_create_data
    else
      flash.now[:notice] = "Data gagal disimpan"
      reload_page("honor-details", 'thr_details')
    end
  end

  def reset_list_thr
    determine_date
    prepare_index
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html 'honors', :partial=> 'list_thr'
          page.replace_html 'filter-period', :partial=> 'periode'
        end
      }
    end
  end

  def download 
    @honor = Honor.find_and_make_sure_user_has_access(params[:id], current_company_id)
    @last_honor = Honor.find(:last, :conditions => [" is_thr = 0  and person_id = ?", @honor.person_id])

    if @honor and @last_honor

      unless @honor.file_name.blank?
        last_file = File.exist?("#{RAILS_ROOT}/thrs/#{@honor.honor_date.year}/#{@honor.honor_date.month}/#{@honor.file_name}")
      end
      # Check if pdf file already generated
      # If yes, pdf should not be generated again

      if !last_file
        generate_thr_receipt
      end

      if !File.exist?("#{RAILS_ROOT}/thrs/#{@honor.get_year}/#{@honor.get_month}/#{@honor.file_name}")
        # Di production pembuatan slip gaji pertama pasti selalu harus 2x
        generate_thr_receipt
      end
      send_file "#{RAILS_ROOT}/thrs/#{@honor.get_year}/#{@honor.get_month}/#{@honor.file_name}"
    else
      redirect_to :back
    end
  end

  # Export salaries data
  def export
    if params[:type] == 'xls'
      export_to_xls 
    elsif params[:type] == 'bca'
      generate_payroll
    else
      redirect_to salaries_path 
    end
  end

  require 'spreadsheet'
  # Generate spreadsheet files
  def export_to_xls
    @honors = Honor.find(:all, :include => [:person], :conditions => current_conditions, :order => 'people.firstname ASC')
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'My First Worksheet'
    sheet1.name = 'My First Worksheet'
    sheet1.row(0).concat ["No", "NIK","NPWP", "Nama Karyawan", "Mulai Kerja", "Bruto THR/Bonus ", "PPH 21 Gaji Per Tahun", "PPH 21 Gaji Pertahun + THR/Bonus", "Pajak THR/Bonus", "THR/Bonus Diterima"]
    format = Spreadsheet::Format.new :weight => :bold, :size => 10
    sheet1.row(0).default_format = format
    @honors.each_with_index do |honor, index|
      person = honor.person
      last_honor = honor.last_non_thr_honor
      if person
        sheet1.row(index+1).concat [index+1,
          person.employee_identification_number,
          person.no_npwp,
           ("#{person.firstname} #{person.lastname}"),
          person.current_employment.employment_start,
          honor.salary,
          last_honor.pph_indebted_per_year,
          honor.pph_indebted_per_year,
          honor.pph_indebted_per_year,
          honor.total_final_take_home_pay]
      end
    end
    
    require 'stringio'
    data = StringIO.new ''
    book.write data

    file_name = "DaftarTHR-#{params[:month_from]}.#{params[:year_from]}-#{params[:month_to]}.#{params[:year_to]}.xls"
    send_data(data.string, :type=>"application/excel", :disposition=>'attachment',:filename => file_name)
  end

  require 'fastercsv'
  # Generate payroll for BCA
  def generate_payroll
    unless params[:transfer_date].blank?
      conditions = "month(honors.honor_date) >= ? AND month(honors.honor_date) <= ? AND year(honors.honor_date) >= ? AND year(honors.honor_date) <= ? and company_id = ?", params[:month_from], params[:year_from], params[:month_to], params[:year_to], current_company_id
      @honors = Honor.find(:all, :include => [:person], :conditions => conditions, :order => 'people.firstname ASC')
      total_transfered = Honor.sum(:final_take_home_pay, :conditions => conditions).to_f
  
      # Get company id
      # TODO: check integration with platform. It should get company_id from platform
      payroll_setting = PayrollSetting.find_by_company_id(@honors.first.person.company_id)
      @transfer_date = params[:transfer_date]

      txt_string = FasterCSV.generate do |txt|
        base_code = "00000000000"                                                     #1-11:tidak digunakan
        bca_brach_code = payroll_setting.bca_branch_code                              #12-15:kode cabang bca
        company_code = payroll_setting.bca_company_code                               #16-20:kode perusahaan (huruf ke-5 = 0)
        company_initial = payroll_setting.bca_company_initial                         #21-24 inisial nama perusahaan
        transfer_date = @transfer_date.to_date.strftime('%d')                         #25-26 tgl transfer
        transfer_code = "01"                                                          #27-28 kode transfer untuk gaji yang selalu 01
        account_number_debited = payroll_setting.bca_company_account_number           #29-38 nomor rekening yg di debet
        account_type = "0"                                                            #39 BCA = '0', Non-bca = '1'
        trsanfer_day_type = "0"                                                       #40 Transfer sebelum hari libur = '0'- Tranfer setelah hari libur = '1'
        transfered_space = "MF"                                                       #41-42 ruang linkup transfer
        total_records_transfered = "%05d" % @honors.count                             #43-47 jumlah total record yg akan ditranfer
        total_salary_transfered = "%017.2f" % total_transfered                        #48-64 jumlah total (gaji + tunjangan) (sudah termasuk 2 angka dibelakang koma)
        month_process = @transfer_date.to_date.strftime('%m')                         #65-66 bulan proses
        year_process = @transfer_date.to_date.strftime('%Y')                          #67-70 tahun proses

        txt << [base_code+bca_brach_code+company_code+company_initial+transfer_date+transfer_code+account_number_debited+account_type+trsanfer_day_type+transfered_space+total_records_transfered+total_salary_transfered+month_process+year_process]
        @honors.each_with_index do |honor, index|
          if honor.person.bank_name == "bca"
            base_employee_code = '0'                                                    #1 '0'
            employee_account_number = honor.person.account_number                       #2-11 nomor rekening yang dkredit
            employee_total_salary = ("%016.2f" % honor.final_take_home_pay).delete"."   #12-26 jumlah total gaji(sudah termasuk 2 angka dibelakang koma)
            employee_number = honor.person.employee_identification_number               #27-36 nomor pegawai
            employee_name = "%030s" % honor.person.account_name                         #37-66 nama pegawai
            departement = honor.person.current_employment.department.department_name     #67-70 dept
            txt << [base_employee_code+employee_account_number+employee_total_salary+employee_number+employee_name+departement]
          end
        end

      end
      filename = "A-Pay"+@transfer_date.to_date.strftime('%Y%m%d')+".txt"
      send_data txt_string,
        :type => 'text; charset=iso8859-1; header=present',
        :disposition => "attachment; filename=#{filename}"
    end

    redirect_to :back
  rescue
    redirect_to salaries_path
  end

  def mine
    @person = current_user.person
    # @honors = @resource.honors.find(:all, :conditions => "status = 'transfered'", :order => 'honor_date ASC')

    conditions = "month(honors.honor_date) >= ? AND month(honors.honor_date) <= ? AND year(honors.honor_date) >= ? AND year(honors.honor_date) <= ?", @month_from, @year_from, @month_to, @year_to
    @honors = @person.honors#(:order => 'honor_date ASC', :conditions => conditions)
    @salaries = @honors.paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html 
      format.js
    end

  end

  # Prepare date for filtering honors date
  # def determine_date(month_from = nil, year_from = nil, month_to = nil, year_to = nil)
  def determine_date
    unless params[:date].blank?
      @month_from = params[:date][:start_month]
      @year_from = params[:date][:start_year]
      @month_to = params[:date][:end_month]
      @year_to = params[:date][:end_year]
    else
      now_month = Time.now.month
      now_year = Time.now.year
      @month_from = now_month
      @year_from = now_year
      @month_to = now_month
      @year_to = now_year
    end
  end

private

  def generate_thr_receipt
    total_salary = "Total dibayarkan bulan ini: #{@template.format_currency(@honor.gross_income)} - #{@template.format_currency(@honor.pph_indebted_per_month)}"
    result_salary = " = #{@template.format_currency(total_salary)}"

    FileUtils.mkdir_p "thrs/#{@honor.get_year}/#{@honor.get_month}"
    file_name = @honor.person.firstname + '_' + @honor.person.lastname + '_'+@honor.honor_date.strftime('%d_%m_%Y')

    Prawn::Document.generate "#{RAILS_ROOT}/thrs/#{@honor.get_year}/#{@honor.get_month}/honor_#{file_name}.pdf" do |pdf|;
      pdf.font_size 9
      pdf.move_down 50
      pdf.text "SLIP THR / BONUS TAHUNAN", :align => :center, :size => 14, :style => :bold
      pdf.move_down 20
      pdf.table [
        ["Bulan", ":", "#{@honor.honor_month}/#{@honor.honor_year}"],
        ["Nama", ":", "#{@honor.person.full_name}"],
        ["KTP", ":", "#{@honor.person.no_ktp}"],
        ["NPWP", ":", "#{@honor.person.no_npwp}"]
      ], :cell_style => { :borders => [] }
      pdf.move_down 20
      salary = []
      salary << ["Perhitungan PPH 21 Tanpa THR", "", ""]
      salary << ["Pendapatan Bruto Pertahun", "", "#{@template.format_currency(@last_honor.gross_income * 12)}"]
      salary << ["Pendapatan Netto Pertahun", "", "#{@template.format_currency(@last_honor.year_net_income)}"]
      salary << ["PPH 21 Pertahun", "", "#{@template.format_currency(@last_honor.pph_indebted_per_year)}"]

      salary_2 = []
      salary_3 = []
      salary_4 = []

      salary_2 << ["Perhitungan PPH 21 Dengan THR / Bonus", "", ""]
      salary_2 << ["Penghasilan Bruto Pertahun", "", "#{@template.format_currency((@honor.gross_income * 12)+@honor.salary)}"]
      salary_2 << ["Penghasilan Netto Pertahun", "", "#{@template.format_currency(@honor.year_net_income)}"]
      salary_2 << ["PPH 21 Pertahun", "", "#{@template.format_currency(@honor.pph_with_thr)}"]

      salary_3 <<  ["PPh 21 Untuk THR / Bonus", "#{@template.number_to_currency(@honor.pph_with_thr,
        :unit => "    Rp.     ", :delimiter => ".", :precision => 0, :format => "%u %n")},-
        #{@template.number_to_currency(@last_honor.pph_indebted_per_year,
        :unit => "- Rp.     ", :delimiter => ".", :precision => 0, :format => "%u %n")},-",
        "#{@template.number_to_currency(@honor.pph_indebted_per_year,
        :unit => "Rp.     ", :delimiter => ".", :precision => 0, :format => "%u %n")},-" ]

      salary_4 << ["Total THR / Bonus Dibayarkan:", "", "#{@template.format_currency(@honor.salary)}"]
      salary_4 <<  ["", "", "#{@template.format_currency(@honor.pph_indebted_per_year)}"]
      salary_4 << ["", "", "#{@template.format_currency(@honor.final_take_home_pay)}"]


      pdf.table salary, :column_widths => { 0 => 210, 1 => 150, 2 => 180}  do
        style(row(0),  :borders => [:top, :left, :right])
        style(row(1),  :borders => [:left, :right] )
        style(row(2),  :borders => [:left, :right] )
        style(row(3),  :borders => [:left, :right, :bottom] )
      end

      pdf.move_down 10
      pdf.table salary_2, :column_widths => { 0 => 210, 1 => 150, 2 => 180} do
        style(row(0),  :borders => [:top, :left, :right] )
        style(row(1),  :borders => [:left, :right] )
        style(row(2),  :borders => [:left, :right])
        style(row(3),  :borders => [:left, :right, :bottom]
        )
      end

      pdf.move_down 10
      pdf.table salary_3, :column_widths => { 0 => 210, 1 => 150, 2 => 180} do
        style(row(0),  :borders => [:top, :left, :right, :bottom] )
      end

      pdf.move_down 20
      pdf.table salary_4,  :column_widths => { 0 => 210, 1 => 150, 2 => 180},
        :cell_style => { :borders => [] }

      pdf.move_down 60
      pdf.text session[:platform_user]['user']['user_company']['name']
      pdf.move_down 90
      pdf.table [[""]], :column_widths => { 0 => 100}, :cell_style => { :borders => [:bottom] }

    end
    @page = params[:page_from]
    @index = params[:cid]

    @honor.file_name = "honor_#{file_name}.pdf"
    @honor.save!

  end

  def after_create_data    
      if params[:honor][:item_kembali] == "lanjut"
        render :update do |page|
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "$('#person-details').hide();"
          page << "$('#honor-details').hide();"
          page << "$('#person-name').val('');"
          page << "$('#honor_salary').val('');"
        end
      else
        determine_date
        prepare_index
        reload_page("div_new", "index","holiday_allowances")
      end
  end

  def after_update_data
      if params[:honor][:item_kembali] == "lanjut"
        render :update do |page|
          page << "$('#honor_salary').val('');"
        end
      else
        determine_date
        prepare_index
        reload_page("div_edit", "index","holiday_allowances")
      end
  end

  def prepare_index
    @per_page = 10    
    company_id = current_company_id
    conditions = "year(honors.honor_date) >= #{@year_from} AND year(honors.honor_date) <= #{@year_to} AND is_thr = true AND honors.company_id = #{company_id}"
    unless params[:filter].blank?
      filter_cond = Honor.find_by_filter(params[:filter])
      conditions << " AND " unless filter_cond.blank?
      conditions << filter_cond
    end
    session[:conditions] = conditions 
    if @is_destroy == true
      params[:page] = params[:current_page] 
      @honors = Honor.paginate(:include => :person, :order => 'people.firstname ASC', :conditions => conditions, :page => params[:page], :per_page => @per_page)
      if @honors.count == 0
        curr_page = params[:page].to_i - 1        
        params[:page] = curr_page.to_s if curr_page > 0      
      end 
    end  
    @honors = Honor.paginate(:include => :person, :order => 'people.firstname ASC', :conditions => conditions, :page => params[:page], :per_page => @per_page)
    @honors_all = Honor.count(:conditions => "is_thr = true AND company_id = #{company_id}")
  end

  def prepare_new    
    time_now = Time.now
    @filter_date = time_now.to_date
    @honor = Honor.new
    unless params[:person_id].blank?
      @person = Person.get_person_name_by_department_and_division(params[:person], current_company_id) 
      if @person
        @current_salary = @person.current_salary.salary unless @person.current_salary.blank?
        @current_salary = @person.current_salary_data_master.basic_salary if !@person.current_salary_data_master.blank? && @current_salary.blank?
      end
    end
  end

  def reload_page(div_name, page_name, url = nil, stop_filter = nil)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html div_name, :partial=> page_name
          page << "stop_filter2()" unless stop_filter.blank?
          page << "$.address.value('#{url}');" unless url.blank?
          page << "$('.notify_error').show();$('.message').html('#{flash.now[:notice]}')" unless flash.now[:notice].blank?
          page << "removeNotifyMessage();"
        end
      }
    end
  end
  
end
