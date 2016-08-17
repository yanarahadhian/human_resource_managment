Feature: update address
  In Order to update address
  As admin
  I want to update address
  so I can update address

  Scenario: Going to update valid address
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I follow "Kompleks Puspa Regency Blok A No 1"
    And I follow "Edit"
    And I fill in "address_state" with "Aceh"
    And I fill in "address_city" with "Agam"
    And I fill in "address_street1" with "Jl. samratulangi"
    And I press "Simpan"
    And I visit to person page with firstname: "nungky"
    And I should see "Jl. samratulangi"
    And I should not see "Kompleks Puspa Regency Blok A No 1"

 Scenario: Going to update invalid address
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I follow "Kompleks Puspa Regency Blok A No 1"
    And I follow "Edit"
    And I fill in "address_city" with ""
    And I fill in "address_street1" with "Jl. samratulangi"
    And I press "Simpan"
    And I visit to person page with firstname: "nungky"
    And I should see "Kompleks Puspa Regency Blok A No 1"
    And I should not see "Jl. samratulangi"