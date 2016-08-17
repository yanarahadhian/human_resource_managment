class AllowancesController < ApplicationController

#  ssl_required
  before_filter :current_features
  before_filter :check_features
  # Check features accessability by user roles
  def check_features
    # case params[:action]
    #   when "index"
    #     current_features.include?('feature_key') ? true : invalid_features 
    # end
    return true
  end

  def index
    render :layout => false
  end

  def new
    render :layout =>'application_setting'
  end

  def show_allowance
    render :layout =>'application_setting'
  end

end
