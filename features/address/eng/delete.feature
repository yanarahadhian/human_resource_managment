Feature: create address
  In Order to create address
  As admin
  I want to create address
  so I can create address

  Scenario: Going to create address
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I check "myrow[ids][]" for "address" with street1: "Kompleks Puspa Regency Blok A No 1"
    And I delete address from person
    Then I should not see "Kompleks Puspa Regency Blok A No 1"
