Feature: list work contract
  In Order to display work contract
  As admin
  I want to display work contract
  so I can see work contract

  Scenario: Going to work contract
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    Then I should see "Kontrak Kerja"
    And I should have 2 work contracts