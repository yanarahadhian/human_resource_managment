Feature: create family
  In Order to create family
  As admin
  I want to create family
  so I can create family

  Scenario: Going to create family
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I check "myrow[ids][]" for "family" with full_name: "Asmiranda"
    And I delete family
    Then I should not see "Asmiranda"
