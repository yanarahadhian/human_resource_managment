Feature: Remove Person
  In order to find important notes faster
  As a Admin
  I want to remove existing person
  So I only have important person

  Scenario: Delete a person
    Given one logged in user
    And I am on the people page
    When I check "myrow[ids][]" for "people" with firstname: "Nungky"
    And I delete people
    Then I should not see "Nungky"