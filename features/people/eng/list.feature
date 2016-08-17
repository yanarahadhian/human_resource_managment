Feature: List Employee
  In Order to see list employee
  As admin
  I want to view list employee
  so I can manage the list employee

 Scenario: Going to list with blank employee
    Given one logged in user
    And 0 employee
    When I go to the people page
    Then I should have 0 person