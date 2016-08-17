Feature: create employment
  In Order to create employment
  As admin
  I want to create employment
  so I can see create employment

  Scenario: Going to list employment
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    Then I should have 2 employment

  Scenario: Going to create employment
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    And I follow "Tambah Jabatan"
    And I fill in "employment_employment_start" with "14/12/2011"
    And I press "Simpan"
    And I visit to employment page with firstname: "nungky"
    Then I should see "14/12/2011"
    And I should have 3 employment