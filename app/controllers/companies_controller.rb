class CompaniesController < ApplicationController
  before_filter :login_required
  before_filter :city_and_state_values, :except => [:destroy]

  ssl_required
  
  def index
    @companies = Company.all
  end

  def show
    @company = Company.find(params[:id])
  end

  def new
    @company = Company.new
    @address = @company.addresses.new
    render :layout => false
  end

  def edit
    @company = Company.find(params[:id])
  end

  def create
    @company = Company.new(params[:company])

    if @company.save
      flash.now[:notice] = "Perusahaan berhasil ditambah !"
      if params[:id].blank?
        redirect_to person_new_experience_path(params[:person_id], params[:experience_type])
      else
        redirect_to edit_person_experience_path(params[:person_id], params[:id])
      end
    else
      render :action => :new
    end
  end

  def update
    @company = Company.find(params[:id])

    if is_approved(params[:username], params[:password]) && @company.update_attributes(params[:company])
      flash.now[:notice] = "Perusahaan berhasil diubah !"
      redirect_to companies_path
    else
      render :action => :edit
    end
  end

  def destroy
    @company = Company.find(params[:id])

    if @company.destroy
      flash.now[:notice] = "Perusahaan berhasil dihapus !"
      redirect_to companies_path
    end
  end
  
  private
  
  def city_and_state_values
    @city = Address.find(:all, :select => "distinct city").map{|m| m.city}.join(',')
    @state = Address.find(:all, :select => "distinct state").map{|m| m.state}.join(',')
  end
end
