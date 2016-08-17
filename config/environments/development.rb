# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
# config.action_mailer.raise_delivery_errors = false
# config.action_mailer.raise_delivery_errors = false
# config.action_mailer.default_url_options = { :host => "localhost:3003" }
# config.action_mailer.delivery_method = :smtp
# config.action_mailer.smtp_settings = {
#     :address              => "smtp.gmail.com",
#     :port                 => 587,
#     :domain               => "hrm.appschef.com",
#     :user_name            => "do-not-reply@appschef.com",
#     :password             => "w4pps4dmin",
#     :authentication       => "plain",
#     :enable_starttls_auto => true
#   }

SERVICE_NAME = "HR"

DOMAIN_LIST = %w{ localhost:3003 }
PROTOCOL_STRING = "http://"
IS_LOCALHOST = true
APPSCHEF_API_KEY = '079284ff5214ab33bfde4591abb0b2aa25da4d63'
SUBDOMAIN = "hrm"
PLATFORM_SUBDOMAIN = ""
