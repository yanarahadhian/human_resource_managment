Feature: show detail employee
  In Order to show employee
  As admin
  I want to show one employee
  so I can see detail employee

  Scenario: Going to show detail person page
    Given one logged in user
    And I am on the people page
    When I go to the person page with firstname: "nungky"
    Then I should see "Informasi Pribadi"
    And I should see "Nungky"
    And I should see "Selection"