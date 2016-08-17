Feature: update family
  In Order to update family
  As admin
  I want to update family
  so I can update family

  Scenario: Going to update valid family
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I follow "Asmiranda"
    And I follow "Edit"
    And I fill in "family_full_name" with "asep"
    And I fill in "family_gender" with "pria"
    And I fill in "family_address_attributes_street1" with "sssss"
    And I press "info_section_save_basic"
    And I visit to person page with firstname: "nungky"
    Then I should see "asep"
    And I should see "sssss"

  Scenario: Going to update invalid family
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I follow "Asmiranda"
    And I follow "Edit"
    And I fill in "family_full_name" with ""
    And I fill in "family_gender" with "pria"
    And I fill in "family_address_attributes_street1" with "sssss"
    And I press "info_section_save_basic"
    And I visit to person page with firstname: "nungky"
    Then I should see "asep"
    And I should not see "sssss"