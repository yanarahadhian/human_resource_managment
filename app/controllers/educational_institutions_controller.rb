class EducationalInstitutionsController < ApplicationController
  before_filter :login_required
  before_filter :city_and_state_values, :except => [:destroy]

  ssl_required
  
  def new
    @education_institution = EducationalInstitution.new
    @address = @education_institution.addresses.new
    render :layout => false
  end
  
  def create
    @education_institution = EducationalInstitution.new(params[:educational_institution])
    if @education_institution.save
      flash.now[:notice] = "Institusi berhasil ditambah !"
    else
      flash.now[:notice] = "Institusi gagal ditambah !"
    end
    if params[:id].blank?
      redirect_to new_person_education_path(params[:person_id])
    else
      redirect_to edit_person_education_path(params[:person_id], params[:id])
    end
  end
  
  private
  
  def city_and_state_values
    @city = Address.find(:all, :select => "distinct city").map{|m| m.city}.join(',')
    @state = Address.find(:all, :select => "distinct state").map{|m| m.state}.join(',')
  end
  
end
