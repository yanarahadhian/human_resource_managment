Feature: show update health
  In Order to update health
  As admin
  I want to show update health
  so I can see update health

  Scenario: Going to show detail health
    Given one logged in user
    And I am on the people page
    When I visit to health page with firstname: "nungky"
    And I fill in "person_weight_in_kg" with "65"
    And I choose "person_blood_type_a"
    And I choose "person_color_blind_ya"
    And I press "simpan" on health page with person firstname : "nungky"
    Then I should see "65"
    And I should see "A"
    And I should see "ya"