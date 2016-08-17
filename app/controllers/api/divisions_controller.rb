class Api::DivisionsController < ApplicationController
  
  skip_before_filter :login_required, :basic_authenticate
  # Get list all divisions
  # curl http://localhost:3003/api/divisions/:company_id
  def show
    divisions = Division.find_all_by_company_id(params[:company_id], :select => "name")
    data = []
    divisions.each do |p|        
     data << p.name
    end
    render :json => data, :status => 200
  end

end
