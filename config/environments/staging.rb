
# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
config.action_mailer.raise_delivery_errors = false
config.action_mailer.default_url_options = { :host => "hrm.testing.appschef.com" }
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => "hrm.testing.appschef.com",
    :user_name            => "do-not-reply@appschef.com",
    :password             => "w4pps4dmin",
    :authentication       => "plain",
    :enable_starttls_auto => true
  }

# Enable threaded mode
# config.threadsafe!

# $domain_inventory = '3000'
# $domain_users = '3001'
# $domain_sdm = '3004'

# APPCHEF_URL = 'https://staging.appschef.com/'
# CALLBACK_URL = 'http://hrm.staging.appschef.com/user_sessions/callback'
# APPLICATION_URL = 'http://hrm.staging.appschef.com'
# APPCHEF_API_KEY = '46148d3e03cdd7ebe32e39a27d2517cdc9799be7'
SERVICE_NAME = "SDM"

# .htaccess
USER_ID, PASSWORD = "admin", "passwordnyapassword"

# CGNP
CGNP_ID = 123
                  
DOMAIN_LIST = %w{ hrm.testing.appschef.com }
PROTOCOL_STRING = "https://"
IS_LOCALHOST = false
APPSCHEF_API_KEY = '079284ff5214ab33bfde4591abb0b2aa25da4d63'
SUBDOMAIN = "hrm"
PLATFORM_SUBDOMAIN = "testing.appschef.com"
APPSCHEF_URL = 'https://testing.appschef.com'
