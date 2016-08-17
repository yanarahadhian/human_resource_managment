Feature: show detail health
  In Order to show health
  As admin
  I want to show one health
  so I can see detail health

  Scenario: Going to show detail health
    Given one logged in user
    And I am on the people page
    When I go to the person page with firstname: "nungky"
    Then I should see "Informasi Pribadi"
    And I should see "Buta warna"
    And I should see "tidak"
    And I should see "O"