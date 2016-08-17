Feature: Show person
   In Order to show person
   I want to see person detail
   so I can manage the person

  Scenario: Going to person index page
    Given one logged in user
    When I go to the people page
    Then I should have 49 person

  Scenario: Going to person detail page
    Given one logged in user
    And I am on the people page
    When I go to the person page with employee_identification_number: "2.94.0173"
    Then I should see "2.94.0173"
    And I should see "Agung Iswanto"

  Scenario: Going to person education detail page
    Given one logged in user
    And I am on the person page with employee_identification_number: "2.94.0173"
    When I see the history page for person with employee_identification_number: "2.94.0173"
    Then I should see "S1"
    And I should see "Pertanian"