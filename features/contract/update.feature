Feature: update work contract
  In Order to update work contract
  As admin
  I want to update work contract
  so I can see work contract

  Scenario: Going to update work contract
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    And I fill in "type_1" with "1"
    And I fill in "type_1" with "1"
    And I fill in "contract_start_1" with "12/12/2011"
    And I fill in "contract_start_1" with "15/12/2011"
    And I fill in "is_pemanent_1" with "1"
    And I fill in "is_daily_1" with "1"
    And I follow "Save"
    And I visit to employment page with firstname: "nungky"
    Then I should see "12/12/2011"
    And I should see "15/12/2011"