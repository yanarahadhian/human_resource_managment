xml.instruct! :xml, :version=>"1.0"

xml.people do
  @people.each do |person|
    xml.person do
        xml.firstname person.firstname
        xml.lastname person.lastname
        xml.fullname person.full_name 
        xml.id person.id
        xml.position ", #{person.current_employment.position.position_name}"  unless person.current_employment.position.blank?
        xml.department ", #{person.current_employment.department.department_name}" unless person.current_employment.department.blank?
    end
  end
end
