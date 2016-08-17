module WPlatformAuthentication
  require 'net/https'


  def call_w_platform_api(api_address)
    begin
      Rails.logger.info "\n\n*****\n Requesting to API :#{api_address}\n\n"

      url = URI.parse(api_address)
      puts "#####  Call address: #{api_address}"
      if Rails.env == 'development'
        if api_address.include?("how_to?hash_name=")
          req = Net::HTTP::Get.new(url.request_uri)
        else
          req = Net::HTTP::Get.new(url.path)
        end
        res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
      else
        req = Net::HTTP.new(url.host, url.port)
        req.use_ssl = true
        req.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http = Net::HTTP::Get.new(url.request_uri)
        res = req.request(http)
      end
      ActiveSupport::JSON.decode(res.body)

    rescue => e
      Rails.logger.info "\n\n*****Something Wrong when access API :#{api_address}\n\n ****Error: #{e.inspect}"
      puts "\n\n*****Something Wrong when access API :#{api_address}\n\n ****Error: #{e.inspect}"
      ""
    end
  end

  def has_active_platform_session?( api_key, session, appschef_url="http://appschef.com")
    active = false
    if !session[:user_log_id].blank? and !session[:platform_user].blank?
      api_address = "#{appschef_url}/api/users/already_logged_out/#{session[:user_log_id]}/#{current_permalink}/#{api_key}"
      result = call_w_platform_api(api_address)
      if result and result["already_logged_out"] and result["already_logged_out"] == "false"
        active = true
      end
    end
    Rails.logger.info "#{result}"
    active
  end

end
