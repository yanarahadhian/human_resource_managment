Feature: list sp from person
  In Order to see list sp from person
  As admin
  I want to view list sp from person
  so I can manage the list sp from person

 Scenario: Going to list sp from person
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    Then I should have 3 memorandums
    And 

 Scenario: Going to create sp from person
    Given one logged in user
    And I am on the employment page with firstname: "nungky"
    When I visit to memorandums page with person firstname: "nungky"
    And I fill in "violation_violation_category" with "Ringan"
    And I fill in "violation_occurence_date" with "12/12/2011"
    And I fill in "violation_action_taken" with "SP1"
    And I fill in "violation_active_until" with "31/12/2011"
    And I press "Simpan"
    And I visit to employment page with firstname: "nungky"
    Then I should have 4 memorandums