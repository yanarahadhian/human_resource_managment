Feature: create family
  In Order to create family
  As admin
  I want to create family
  so I can create family

  Scenario: Going to create family
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I follow "Tambah Keluarga"
    And I fill in "family_full_name" with "Vita"
    And I fill in "family_gender" with "wanita"
    And I fill in "family_address_attributes_street1" with "jalan jakarta"
    And I press "Simpan"
    And I visit to person page with firstname: "nungky"
    Then I should see "Vita"