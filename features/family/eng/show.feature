Feature: show family
  In Order to display show family
  As admin
  I want to display show family
  so I can see show family

  Scenario: Going to show family
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I follow "Asmiranda"
    Then I should see "Edit"
    And I should see "Asmiranda"
    And I should see "wanita"