 Feature: In Order to update employment
  As admin
  I want to update employment
  so I can see update employment

  Scenario: Going to list employment
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    Then I should have 2 employment
    And I should see "01/12/2011"
    And I should see "Anggota"

  Scenario: Going to update employment
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    And I follow "01/12/2011"
    And I follow "Edit"
    And I fill in "employment_employment_start" with "2012-08-25"
    And I fill in "employment_position_id" with "102"
    And I press "Simpan"
    And I visit to employment page with firstname: "nungky"
    Then I should see "25/08/2012"
    And I should see "Foreman"
    And I should not see "01/12/2011"
    And I should not see "Anggota"