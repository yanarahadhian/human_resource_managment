Feature: create employee
  In Order to create employee
  As admin
  I want to create one employee
  so I have new employee

  Scenario: Going to create valid employee
    Given one logged in user 
    When I go to the new person page
    And I fill in "person_firstname" with "Andi"
    And I fill in "person_lastname" with "Ramadhan"
    And I fill in "person_employee_identification_number" with "33"
    And I fill in "person_tax_status_id" with "1"
    And I fill in "person_employment_date" with "28/11/2011"
    And I press "info_section_save_basic"
    Then I should have 3 person

  Scenario: Going to create invalid employee
    Given one logged in user
    When I go to the new person page
    And I fill in "person_firstname" with "Vita"
    And I fill in "person_lastname" with "Dewi"
    And I fill in "person_employee_identification_number" with ""
    And I fill in "person_tax_status_id" with "1"
    And I fill in "person_employment_date" with "28/11/2011"
    And I press "info_section_save_basic"
    Then I should have 2 person