Feature: list address
  In Order to display list address
  As admin
  I want to display list address
  so I can see list address

  Scenario: Going to list address
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    Then I should see "Informasi Alamat"
    And I should see "Bandung barat"