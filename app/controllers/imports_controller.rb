class ImportsController < ApplicationController
  before_filter :login_required

  ssl_required :check_features
  before_filter :current_features
  before_filter :check_features, :only => [:create]
  # Check features accessability by user roles
  layout = false
  def check_features
    case params[:action]
      when "create"
        current_features.include?('employee_import') ? true : invalid_features 
      end
    # return true
  end

	def create
    flash[:notice] = "Data karyawan gagal diimport"
    unless params[:import].blank?
      @import = Import.new(params[:import].merge(:company_id => current_company_id))
      if @import.save
        str_callback = @import.import_to_db1
        flash[:notice] = str_callback
      end
    end
   redirect_to "#{ApplicationController::BASE_URL}/a/#{current_permalink}#person_index"
  end
  
  def create_for_absent
    flash[:notice] = "Data Absen karyawan gagal diimport"
    unless params[:import].blank?
      @import = Import.new(params[:import].merge(:company_id => current_company_id))
      if @import.save
        str_callback = @import.import_presence_from_excell
        flash[:notice] = str_callback
        #flash[:notice] = 'File was successfully imported.'
        #redirect_to articles_path
      end
     render :text => "<html><body><script type='text/javascript'>parent.$.fn.colorbox.close();parent.location.reload();</script></body></html>"
    end
  
  end

end
