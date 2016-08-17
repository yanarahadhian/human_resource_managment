Feature: list family
  In Order to display list family
  As admin
  I want to display list family
  so I can see list family

  Scenario: Going to list family
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    Then I should see "Data Keluarga"
    And I should see "Asmiranda"