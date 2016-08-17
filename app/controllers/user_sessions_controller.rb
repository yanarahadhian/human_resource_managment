class UserSessionsController < ApplicationController

  # #FIXME: Di sini layout di definisikan, beberapa baris ke bawah juga ada
  layout false
  #before_filter :flatform_session
  skip_before_filter :login_required, :except => :destroy
  skip_before_filter :user_session_active_required, :only => [:new, :callback]

  # Use this for multi company permalik check
  before_filter :check_permalink, :only => :new

  layout 'application2'
  ssl_required :after_login, :callback, :logout_confirm, :logout_confirmed

  CALLBACK_URL = "#{ApplicationController::BASE_URL}/user_sessions/callback" #'http://localhost:3002/callback/a/'
  def new
    if !current_user.blank? && !session[:platform_user].blank?
      render :layout => 'application2'      
    else
      url = "#{APPSCHEF_URL}/api/login?service=#{SERVICE_NAME}&continue=#{CALLBACK_URL}"
      url << "/a/#{params[:permalink]}#person_index?tab=is_login" unless params[:permalink].blank?
      redirect_to url
    end
  end

  def after_login
    if params[:data].blank?
      flash.now[:error] = "Logged in failed"
      render :action => 'new'
    else
      user = Hash.from_xml(params[:data])
      session[:user] = user["user"]
      flash.now[:notice] = "Logged in successfully"
    end
  end

  # callback url, retrieve token string from platform
  # logged in user if exist or create new user
  def callback
    platform_user = User.setup_platform_user(params[:token_string],params[:permalink])
 
    if platform_user.blank? || platform_user==false || platform_user['token'] == "invalid api key" || platform_user.blank? || platform_user['user']['features'].blank?
      redirect_to "#{APPSCHEF_URL}"
    else
      session[:platform_token] = params[:token_string]
      session[:user_log_id] = params[:user_log_id]
      session[:platform_user] = platform_user
      if self.current_user.nil?
        new_user = User.create_from_platform(platform_user['user'], params[:token_string]) unless platform_user['user'].blank?
        unless new_user
         flash.now[:notice] = "Invalid login"
         redirect_to company_callback_url(params[:permalink])
        else
          self.current_user = new_user
        end
      end
      session[:product] = User.get_menu_header(session[:platform_token],params[:permalink])
      session[:is_after_login] = true      
      HrSetting.initializer(current_company_id)
      redirect_to "/a/#{params[:permalink]}#person_index?tab=is_login"
    end
  end

  def destroy
    @token_string = session[:platform_token]
    session[:company_permalink] = nil
    session[:platform_token] = nil
    session[:user_log_id] = nil
    begin
      logout_killing_session!
      redirect_to "#{ApplicationController::APPSCHEF_URL}/api/users/#{@token_string}/logout/#{APPSCHEF_API_KEY}"
    rescue
      Rails.logger.info "************** \n Error when logout : #{e.inspect} \n"
      redirect_to "#{ApplicationController::APPSCHEF_URL}"
    end
  end

  def logout_confirm
    render :layout => 'confirmation'
  end

  def logout_confirmed
    if params[:logout].blank?
      redirect_to :back
    elsif params[:logout] == "logout"
      redirect_to "/logout"
    elsif params[:logout] == "dashboard"
      redirect_to "/a/" + session[:platform_user]['user']['user_company']['permalink'].to_s + "#dashboard"
    end
  end

  private

  # Use this for multi company permalink check
  #
  def check_permalink
    if !params[:permalink].blank? && !session[:platform_user].blank? && params[:permalink] != session[:platform_user]['user']['user_company']['permalink'].to_s
      redirect_to logout_confirm_user_sessions_path
    end
    return true
  end

end
