Feature: Terminasi employment
  In Order to terminasi employment
  As admin
  I want to terminasi employment
  so I can see list after delete employment

  Scenario: Going to list employment
    Given one logged in user
    When I visit to employment page with firstname: "nungky"    
    Then I should have 2 employment

 Scenario: Going to terminasi employment
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    And I follow "Terminasi"
    And I fill in "ui-date" with "09/12/2011"
    And I press "OK"
    When I visit to employment page with firstname: "nungky"
    Then I should see "resign tanggal 09/12/2011"
    Then I should have 3 employment