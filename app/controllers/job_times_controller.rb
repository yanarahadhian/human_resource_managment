class JobTimesController < ApplicationController
  ssl_required
  def index
    render :layout => "application_setting"
  end

  def new
    render :layout => "application_setting"
    @hr = HrSetting.find(:first)
    @contract = ContractType.find(:all);
  end

  def edit
    render :layout => "application_setting"
  end

  def create
    redirect_to new_job_time_path
  end

end