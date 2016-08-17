Feature: List Person
  In Order to see all person
  As admin
  I want to view all person
  so I can manage the person

  Scenario: Going to person index page
    Given one logged in user
    When I go to the people page
    Then I should have 49 person