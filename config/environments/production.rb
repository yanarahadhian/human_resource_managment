# Settings specified here will take precedence over those in config/environment.rb

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
config.action_mailer.default_url_options = { :host => "hrm.appschef.com" }
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => "hrm.appschef.com",
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

# APPCHEF_URL = 'http://www.appschef.com/'
# CALLBACK_URL = 'http://hrm.appschef.com/user_sessions/callback'
# APPLICATION_URL = 'http://hrm.appschef.com'
# APPCHEF_API_KEY = 'e570ed95d0aef1f7bc3ae3ca1776eb9feb55d896'
SERVICE_NAME = "HR"

# .htaccess
USER_ID, PASSWORD = "admin", "passwordnyapassword"

DOMAIN_LIST = %w{ hrm.staging.private.appschef.com staging.private.appschef.com hrm.staging.private.appschef.com:443}
PROTOCOL_STRING = "https://"
IS_LOCALHOST = false
APPSCHEF_API_KEY = "2b5c8e4f9952798e023474559bc852b2c59da56d"
SUBDOMAIN = "hrm"
PLATFORM_SUBDOMAIN = "staging.private.appschef.com"
APPSCHEF_URL = "https://staging.private.appschef.com"
