class PromotionsController < ApplicationController
  helper_method :sort_column, :sort_direction
  ssl_required :check_features
  before_filter :current_features
  before_filter :check_features, :only => [:index]
  # Check features accessability by user roles  
  def check_features
    case params[:action]
      when "index"
        current_features.include?('promotion_index') ? true : invalid_features 
      end
    # return true
  end

  def index
    add_breadcrumb "Karyawan", "#person_index"
    add_breadcrumb "Promosi karyawan", "#promotions"
    params[:sort]= "firstname" if params[:sort] == "nama"    
    str_by_company =  " AND people.company_id=#{current_company_id}"
    if params[:filter].blank?
      session[:conditions] = Person.with_promotion + str_by_company
    else
      session[:conditions] = Person.with_promotion(params[:filter]) + str_by_company
    end
    @per_page = 10
    @employments = Employment.paginate(:include => [:person], :conditions => current_conditions, :page => params[:page], :per_page => @per_page, :order => sort_column + " " + sort_direction)
    respond_to do |format|
      format.html { render :layout => false }
      format.js {
        render :update do |page|
          page.replace_html 'div_list_promotions', :partial=> 'list_promotions'
          page << "stop_filter()"
        end
      }
    end    
  end

  private

  def sort_column
    Person.column_names.include?(params[:sort]) ? params[:sort] : "people.firstname"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end