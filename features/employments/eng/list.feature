Feature: list employment
  In Order to display list employment
  As admin
  I want to display list employment
  so I can see list employment

  Scenario: Going to list employment
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    Then I should see "Data Jabatan"
    And I should see "Accounting"
    And I should see "Anggota"
    And I should see "masuk_kerja"
    And I should see "01/12/2011"
    And I should have 2 employment