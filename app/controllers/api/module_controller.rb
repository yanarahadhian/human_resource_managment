class Api::ModuleController < ApplicationController
  # layout false

  before_filter :validate_api_user
  skip_before_filter :login_required, :basic_authenticate
  skip_before_filter :verify_authenticity_token 

  # validate params[:token_string] vs params[:permalink] vs params[:hash_key]
  def validate_api_user
    # @response = User.get_api_from_platform("#{APPSCHEF_URL}/api/users/#{params[:token_string]}/#{APPSCHEF_API_KEY}/#{params[:permalink]}")
    @response = User.get_api_from_platform("#{ApplicationController::APPSCHEF_URL}/api/user_detail/#{params[:token_string]}/#{APPSCHEF_API_KEY}/#{params[:permalink]}")
    if @response['user'].present? and @response['user']['login_time'].present?
      hash = Digest::SHA1.hexdigest(@response['user']['login_time'])
    elsif @response['user']['login_time'].blank?
      render :json => 'Response error', :status => 400
    elsif @response.blank?
      render :json => 'Platform error', :status => 400
    end

    # if hash != params[:hash_key]
    #   RAILS_DEFAULT_LOGGER.info("\n\n\nDEBUG: validate_api_user::hash\n#{hash} vs #{params[:hash_key]}\n\n")
    #   render :json => 'Authentication error', :status => 401
    # end
    # rescue
    # render :json => "Token error"

    if @response['token'] == "invalid api key" 
      render :json => 'invalid api key', :status => 400
    end
  end
end