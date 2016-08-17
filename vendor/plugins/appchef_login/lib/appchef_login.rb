# AppchefLogin
module AppchefLogin

  PLATFORM_ERROR = "platform_error"

  module ViewHelper
    def appchef_login_button
      html = <<-"HTML"
        <script type='text/javascript'>
          function login_form() {
            newwindow=window.location.href = ('#{APPCHEF_URL}api/login?service=Warehouse&continue=#{CALLBACK_URL}');
            if (window.focus) {newwindow.focus()}

          }
        </script>
        <p>
          <a href="#" onclick="login_form();return false;" class="blue_button" style="margin-top:0; color:white; !important">Login</a>
        </p>
      HTML
      return raw html
    end

    def appchef_logout_button(logout_link, token_string, permalink=nil)
      #newwindow=window.open('#{APPCHEF_URL}/api/users/#{token_string}/logout/8663272fd4b28ade17ed4ddf11dcfdfcb270950a','logout','height=400,width=600');
      #newwindow=window.open('#{APPCHEF_URL}/logout?api=true','logout','height=400,width=600');
      html = <<-"HTML"
        <script type='text/javascript'>
          function logout_form() {
            newwindow=window.location.href = ('#{APPCHEF_URL}api/users/#{token_string}/logout/8663272fd4b28ade17ed4ddf11dcfdfcb270950a');
            window.location.href = '#{logout_link}';
          }
        </script>
          <a href="#" onclick="logout_form();return false;" class="fb_menu_link">Logout</a>
      HTML
      return raw html
    end

  end

  module ModelHelper
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def appchef_login
        include AppchefLogin::ModelHelper::InstanceMethods
        extend AppchefLogin::ModelHelper::SingletonMethods
      end
    end

=begin
uri = URI.parse("https://secure.com/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)
=end

    module SingletonMethods
      def get_platform_user(token_string, permalink=nil)
        #require 'net/http'
        require 'net/https'

        url = URI.parse("#{APPCHEF_URL}/api/users/#{token_string}/#{APPCHEF_API_KEY}/#{permalink}")

        if RAILS_ENV=='development'
          req = Net::HTTP::Get.new(url.path)
          res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
        else
          req = Net::HTTP.new(url.host, url.port)
          req.use_ssl = true
          req.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http = Net::HTTP::Get.new(url.request_uri)
          res = req.request(http)
        end
        RAILS_DEFAULT_LOGGER.info "\n\n*****\njson return\n#{res.body.inspect}\n\n"
        platform_user = ActiveSupport::JSON.decode(res.body)

        platform_user
      rescue => e
        RAILS_DEFAULT_LOGGER.info "\n\n*****\nDEBUG get_platform_user\nerror: #{e.inspect}\n\n"
        RAILS_DEFAULT_LOGGER.info "\n\n*****\nDEBUG json return\n#{res.body.inspect}\n\n"
        PLATFORM_ERROR
      end
    end

    module InstanceMethods
      # instance method
    end
  end
end

