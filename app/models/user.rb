class User < ActiveRecord::Base
   self.abstract_class = true

   include Authentication
   include Authentication::ByPassword
   include Authentication::ByCookieToken

   belongs_to :role
   appchef_login
   has_many :user_companies
   has_one :person

  # APPSCHEF_URL = "http://localhost:3000"
   MFG_URL = "http://localhost:3005"

   def self.create_from_platform(platform_user, token_string)
     new_user = User.new(data_user(platform_user))
     new_user.token_string = token_string
     new_user.save(false)
     return new_user
   end

   def self.data_user(platform_user)
     {:name => "#{platform_user['first_name']} #{platform_user['last_name']}", :login => platform_user['login'],
      :password => "", :email => platform_user['email'],
      :company_id => platform_user['user_company']['id']
     }
   end

   def self.setup_platform_user(token_string, permalink)
     get_api_from_platform("#{APPSCHEF_URL}/api/users/#{token_string}/#{APPSCHEF_API_KEY}/#{permalink}")
   end

   def self.get_menu_header(token_string, permalink)
     # platform_user = get_platform_user(token_string, permalink)
     platform_user = get_api_from_platform("#{APPSCHEF_URL}/api/users/#{token_string}/#{APPSCHEF_API_KEY}/#{permalink}")
     # platform_user = get_api_from_platform("#{ApplicationController::APPSCHEF_URL}/api/users/#{token_string}/#{APPSCHEF_API_KEY}/#{permalink}")
     return platform_user['user']['products'] unless platform_user['user'].blank?
     return nil
   end

  def self.get_api_from_platform(api_address)
    require 'net/https'
    url = URI.parse(api_address)
    if RAILS_ENV == 'development'
      # if api_address.include?("how_to?page_url=")
      if api_address.include?("howto?hash_name=")
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
    RAILS_DEFAULT_LOGGER.info "\n\n*****\njson return\n#{res.body.inspect}\n\n"
    result = ActiveSupport::JSON.decode(res.body)

    return result
  end


end
