Feature: create address
  In Order to create address
  As admin
  I want to create address
  so I can create address

  Scenario: Going to create with valid address
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I follow "Tambah Alamat"
    And I fill in "address_state" with "Bengkulu"
    And I fill in "address_city" with "Kab. Bengkulu Selatan"
    And I fill in "address_street1" with "Jl Jakarta 39"
    And I press "Simpan"
    And I visit to person page with firstname: "nungky"
    Then I should see "Bengkulu"
    And I should see "Kab. Bengkulu Selatan"

Scenario: Going to create with invalid address
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I follow "Tambah Alamat"
    And I fill in "address_state" with ""
    And I fill in "address_city" with "Kab. Bengkulu Selatan"
    And I fill in "address_street1" with "Jl Jakarta 39"
    And I press "Simpan"
    And I visit to person page with firstname: "nungky"    
    And I should not see "Kab. Bengkulu Selatan"