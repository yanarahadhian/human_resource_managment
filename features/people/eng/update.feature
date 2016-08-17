Feature: update employee
  In Order to update employee
  As admin
  I want to update one employee
  so I have new employee

Scenario: Going to edit person page
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I go to the edit person page with firstname: "nungky"
    Then I should see "Field dengan tanda * harus diisi"
    And I should see "Nungky"

Scenario: Going to update person with valid data
    Given one logged in user
    And I am on the edit person page with firstname: "nungky"
    And I fill in "person_lastname" with "Irawan"
    And I fill in "person_tax_status_id" with "1"
    And I fill in "person_employment_date" with "28/11/2011"
    And I fill in "person_employee_identification_number" with "11"
    And I press "Simpan"
    And I go to the person page with firstname: "nungky"
    Then I should see "Edit Informasi Karyawan"
    And I should see "Irawan"
    And I should see "11"

Scenario: Going to update person with invalid data
    Given one logged in user
    And I am on the edit person page with firstname: "nungky"
    And I fill in "person_lastname" with "Irawan"
    And I fill in "person_tax_status_id" with ""
    And I fill in "person_employment_date" with ""
    And I fill in "person_employee_identification_number" with ""
    And I press "Simpan"
    And I go to the person page with firstname: "nungky"
    Then I should see "Selection"
    And I should see "11"