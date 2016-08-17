class Api::PeopleController < Api::ModuleController

  skip_before_filter :login_required, :basic_authenticate
  before_filter :prepare_company
  
  # curl http://localhost:3003/people/employee/:token_string/:permalink/:hash_key
  def employee
    unless @company.blank?
      conditions = "company_id = #{@company.company_id} AND latest_employment_id not in (select id from employments where change_from_before='terminasi') AND latest_employment_id IS NOT NULL"
      people = Person.find(:all, :include =>[:employments],  :conditions => conditions)
      employee = []
      index = 1
      people.each do |person|
        employee << {
          "fullname" => (person.full_name.titleize unless person.blank?),
          "position_id" => (person.current_employment.position_id unless person.current_employment.position_id.blank?),
          "position_name" => (person.current_employment.position.position_name unless person.current_employment.position.blank?)
        }
        index += 1
      end
      render :json => employee.to_json
    else
      answer_json('token','invalid token string',401)
    end
  end

  # curl http://localhost:3003/people/position_name/:position_id/:token_string/:permalink/:hash_key
  def position_name
    unless @company.blank?
      conditions = "company_id = #{@company.company_id}"
      position = Position.find_by_id(params[:position_id], :conditions => conditions)
      unless position.blank?
        render :json => position.position_name.to_json
      else
        answer_json('position','position not found',401)  
      end
    else
      answer_json('token','invalid token string',401)
    end
  end

  private
  def prepare_company
    @company = User.find_by_token_string(params[:token_string])
  end

end
