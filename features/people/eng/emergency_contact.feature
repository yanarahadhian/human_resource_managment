Feature: show manage health
  In Order to manage health
  As admin
  I want to show manage health
  so I can see manage health

  Scenario: Going to show emergency contact
    Given one logged in user
    When I visit to person page with firstname: "nungky"
    Then I should see "Rama"
    And I should see "02291984910"

Scenario: Going to update emergency contact
    Given one logged in user
    And I am on the person page with firstname: "nungky"
    When I follow "Kontak Darurat"
    And I follow "Edit Kontak Darurat"
    And I fill in "person_nama_kontak_darurat" with "Reacha"
    And I fill in "person_no_telp_kontak_darurat" with "02260908011"
    And I press "Simpan"
    And I visit to person page with firstname: "nungky"
    Then I should see "Reacha"
    And I should see "02260908011"
    And I should not see "Rama"
    And I should not see "02291984910"
    
    