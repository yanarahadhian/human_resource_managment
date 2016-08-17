# Include hook code here
require 'appchef_login'
ActionView::Base.send :include, AppchefLogin::ViewHelper
ActiveRecord::Base.send :include, AppchefLogin::ModelHelper
