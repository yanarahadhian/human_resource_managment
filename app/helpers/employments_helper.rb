module EmploymentsHelper
  def set_data_bagian(employment, current_company_id)
    division = []
    style = "display:none"
    unless employment.division.blank? || employment.department.blank?
      division = Division.by_company(current_company_id).all(:conditions=> "department_id=#{employment.department_id}")
      style = ""
    end
    return {:style => style, :division => division}
  end

  def set_data_group(employment, current_company_id)
    group = []
    style = "display:none"
    unless employment.work_group.blank? || employment.division.blank?
      group = WorkGroup.by_company(current_company_id).all(:conditions=> "division_id=#{employment.work_division_id}")
      style = ""
    end
    return {:style => style, :group => group}
  end
end
