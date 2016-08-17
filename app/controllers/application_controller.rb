# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_features
  helper_method :current_company_id
  helper_method :current_permalink
  helper_method :current_root_url
  helper_method :current_company
  helper_method :current_people
  helper_method :current_count_people

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  require "class_custom_extensions"
  require "spreadsheet"
  include AuthenticatedSystem
  include WPlatformAuthentication
  include ExceptionNotification::Notifiable

  # This method just like htacces
  before_filter :is_internet_connection
  rescue_from Exception, :with => :rescue_unhandled_exceptions if Rails.env != "development"
  # Exception Notifier
  include SslRequirement
  ssl_required :all #:index, :create, :edit, :update, :new, :show, :destroy

  before_filter :login_required

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  before_filter :prepare_server_name

  before_filter :check_domain
  before_filter :user_session_active_required
  before_filter :check_company_data
  before_filter :current_cron_use

  BASE_URL = 'http://localhost:3003'
  APPSCHEF_URL = 'http://localhost:3000'

  def prepare_person
    @departments_app = {"PR" => "Produk","MR" => "Market","IT"=>"Teknologi","SDM"=>"Sumberdaya"}
    @positions_app = {"ITS"=> "IT Staff","SU" => "Staf Umum","SK" => "Staf Keuangan"}
    @divisions_app = {"PR" => {
        "HT" => "Hot plate" ,
        "WB" => "Water Bath" ,
        "TP" => "Tissue Processor"
      },
      "MR" => {
        "RSA" => "Market Research Analyst",
        "PR" => "Public Relation"
      },
      "IT" => {
        "IS" => "IT Support" ,
        "DBA" => "Database Administrator",
        "PROG" => "Programmer"
      },
      "SDM"=> {"HR" => "Human Resource",
        "SH"   => "staff Hr"
      }
    }
    @work_group_app = {"HT" => "Hot_plate" ,
      "WB" => "Water_Bath" ,
      "TP" => "Tissue_Processor",
      "RSA" => "Market_Research_Analyst",
      "PR" => "Public_Relation",
      "IS" => "IT_Support" ,
      "DBA" => "Database_Administrator",
      "PROG" => "Programmer",
      "HR" => "Human_Resource",
      "SH"   => "staff_Hr"
    }
    @work_time_app = {"Normal" => {"start" => "08:00:00","end" => "16:00:00","kode" => "Shift1","break" => 60,"overtime" => 60, "hours" => 7,"offday" => 7,"hour_perweek" => 40},
      "Middle" => {"start" => "15:00:00","end" => "23:00:00","kode" => "Shift2","break" => 60,"overtime" => 60, "hours" => 7,"offday" => 6,"hour_perweek" => 40},
      "Midnight" => {"start" => "22:00:00","end" => "06:00:00","kode" => "Shift3","break" => 60,"overtime" => 60, "hours" => 7,"offday" => 3,"hour_perweek" => 40}
    }
    @person_app = {:name => ["Dani","Ryan","Yanto","Iwan","Feby","Every","Nana","Wahyu","Himawan","Yusuf","Mahendri","Ani","Diani","Puri","Puspita"],
      :gender => ["Laki","Wanita"],
      :city => ["Soreang","Ngamprah","Cikarang","Cibinong","Ciamis","Cianjur","Garut","Indramayu","Karawang","Kuningan","Parigi","Purwakarta","Pelabuanratu","Sumedang","Bandung","Bekasi","Bogor","Cimahi","Cirebon","Cisaat","Tasikmalaya"],
      :marital_status => ['Tidak menikah','Menikah','Bercerai','Janda/Duda'],
      :blood_type => ['a','b','ab','o'],
      :religion => ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Budha', 'Konghucu'],
      :blood_type => ["A","AB","B","O"],
      :color_blind => ["ya","tidak"],
      :contract_type => {"percobaan" => 
          {"duration" => 3 ,"daily" => true,"permanent" =>true},
        "prapermanent-kesatu"  =>
          {"duration" => 12 ,"daily" => true,"permanent" =>true},
        "prapermanent-kedua"  =>
          {"duration" => 12 ,"daily" => true,"permanent" =>true}
      }
    }
    @employment_type_app = ["Kontrak","Tetap","Magang"]
    @basic_salary_app = [2500000,3000000,3500000]
    @cut_cooperation_app = [0,25000,50000]
  end

  def check_company_data
    if params[:controller] != "user_sessions" and params[:action] != "destroy"
      prepare_person
      unless session.blank?
        # BUAT IF APABILA DATA DEPARTMENT POSITION DIVISION MASIH KOSONG MAKA SCRIPT DIBAWAH INI AKAN DIJALANKAN #
        division_app = Division.find_by_company_id(current_company_id)
        department_app = Department.find_by_company_id(current_company_id)
        position_app = Position.find_by_company_id(current_company_id)
        if division_app.blank? && department_app.blank? && position_app.blank?
          puts "#########################################################"
          puts "RUNNNG SEED DATA COMPANY #{current_company_id}"
          holding_id = HoldingCompany.check_data(current_company_id,current_company)
          Department.check_data(current_company_id,@departments_app)
          Position.check_data(current_company_id,@positions_app)
          Division.check_data(current_company_id,holding_id,@divisions_app)
          EmploymentType.check_data(current_company_id,@employment_type_app)
          WorkGroup.check_data(holding_id,current_company_id,@work_group_app)
          WorkTime.check_data(current_company_id,@work_time_app)
          ContractType.check_data(current_company_id,@person_app)
          Person.check_data(current_company_id,holding_id,@person_app,current_company,current_user)
          puts "#########################################################"
        else
          check_absensi = Presence.find_by_company_id(current_company_id)
          if check_absensi.blank?
            holding_id = HoldingCompany.find_by_company_id(current_company_id)
            SalaryMasterData.check_data(current_company_id,holding_id,@basic_salary_app,@cut_cooperation_app)
            EmployeeShift.check_data(current_company_id,holding_id)
            Presence.check_data(current_company_id,holding_id)
            Honor.check_data(current_company_id,holding_id)
          end
        end
      end
    end
  end

  def user_session_active_required
    if params[:controller] != "user_sessions" and params[:action] != "destroy"
      unless has_active_platform_session?(APPSCHEF_API_KEY, session, APPSCHEF_URL)
        session[:platform_user] = nil
        session[:user_log_id] = nil
        render :file => "#{RAILS_ROOT}/public/error_page/no_access.html"
      end
    end
  end

  def check_domain
    unless IS_LOCALHOST
      domain = request.env["HTTP_HOST"]
      #RAILS_DEFAULT_LOGGER.info "\nDEBUG: ApplicationController#check_domain\ndomain: #{domain}\ndomain list: #{DOMAIN_LIST.inspect}\nsubdomain: #{request.subdomains.inspect}\nRAILS_ENV: #{RAILS_ENV.inspect}\n---------------------\n"
      if DOMAIN_LIST.include? domain
        platform_url = domain.gsub("#{request.subdomains.first}.", '')
        # setelah domain ketauan, set semua domain pake yg udah ditentuin.
        # jadi constant APPSCHEF_URL, dll udah ga ada di env lg.
        #User.const_set("APPSCHEF_URL", "#{PROTOCOL_STRING}#{platform_url}/")
        User.const_set("MFG_URL", "#{PROTOCOL_STRING}mfg.#{platform_url}/")
        UserSessionsController.const_set("CALLBACK_URL", "#{PROTOCOL_STRING}#{domain}/user_sessions/callback")
        ApplicationController.const_set("BASE_URL", "#{PROTOCOL_STRING}#{domain}/")
        ApplicationController.const_set("APPSCHEF_URL", "#{PROTOCOL_STRING}#{platform_url}/")
      else
        render :text => "Page Not Found", :status => 404
      end
    end
  end

  def ajax_educational_institution
    educational_institutions = EducationalInstitution.find(:all, :conditions => ['institution_name LIKE ? OR institution_name LIKE ? OR
      institution_name LIKE ? ', params[:q]+'%', '%'+params[:q]+'%', '%'+params[:q]])
    data = educational_institutions.map { |c| "#{c.institution_name}|#{c.id}" }.join("\n")
    data += "\nTidak ada institusi yang sesuai, saya mau input baru|0"
    render :text => data
  end


  def filter_action(section)
    begin
      correlation = UserCorrelation.first(:conditions => ["user_correlations.user_id = ? and sections.controller_name = ? and actions.action_name = ?", current_user.id, section, params[:action]], :joins => [:feature => [:section, :action]])
      if correlation.blank?
        render :text => "Maaf, Anda tidak memiliki hak akses ke fitur ini. Hubungi administrator Anda."
      end
    rescue
      redirect_to "/"
    end
  end

  # Respond for forbiden features
  def invalid_features
    respond_to do |format|
      format.html {render :nothing => true, :status => 401}
    end
  end

  def is_internet_connection
    # require 'socket'
    # begin
    #   TCPSocket.new 'google.com', 80
    # rescue SocketError
    #   render :text => "Tidak dapat menghubungi server. Mohon periksa koneksi internet Anda."
    # end
    true
  end

  def current_features
    unless session[:platform_user]['user']['features'].blank?
      session[:platform_user]['user']['features'].map{|x| x['key']}
    else
      ''
    end
  end

  def current_conditions
    unless session[:conditions].blank?
      session[:conditions]
    else
      return ""
    end
  end

  def current_company
    session[:platform_user]['user']['user_company']['name']
  end

  def current_sort
    unless session[:sort].blank?
      session[:sort]
    else
      return ""
    end
  end

  def current_company_name
    session[:platform_user]['user']['user_company']['name']
  end

  def current_company_id
    session[:platform_user]['user']['user_company']['id'].to_i
  end

  def current_permalink
    session[:platform_user]['user']['user_company']['permalink']
  end

  def current_root_url
    "#{ApplicationController::BASE_URL}/a/#{session[:platform_user]['user']['user_company']['permalink']}"
  end

  def current_people
    return Person.find(:all, :include =>[:employments],  :conditions => people_conditions)
  end

  def current_count_people    
    return Person.find(:all, :select => "count(*) as count", :include =>[:employments],  :conditions => people_conditions)
  end

  def current_cron_use
    # puts session[:platform_user]['user'].nil?
    if session[:platform_user].present? && session[:platform_user]['user'].present? && session[:platform_user]['user']['user_company'].present? && session[:platform_user]['user']['user_company']['id'].present?
      CronUse.create(:company_id => current_company_id) unless CronUse.find(:first).present?
    end
    # return false
  end

  def rescue_unhandled_exceptions(exception)
    notify_about_exception(exception)
    file_path = "#{RAILS_ROOT}/public/error_page/error_global.html"
    Rails.logger.info "\n *************** Unexpected error: #{exception.inspect}"
    case exception
    when ActiveRecord::RecordNotFound
      render :file => file_path
    when ActionController::RoutingError, ActionController::UnknownController, ActionController::UnknownAction
      render :file => file_path
    else
      render :file => file_path
    end
  end

  private

  def people_conditions
    "company_id = #{current_company_id} AND #{Person.without_keluar_masuk}"
  end
  
  def prepare_server_name
    @server_name = request.env['HTTP_HOST'].split(':').first
  end

  protected
  alias :original_ssl_require? :ssl_required?
  def ssl_required?
    Rails.env == 'development' ? false : original_ssl_require?
  end

  def local_request?
    false
  end

end

