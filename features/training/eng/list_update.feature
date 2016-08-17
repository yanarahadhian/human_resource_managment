Feature: Update Training
  In Order to see list and update training
  As admin
  I want to view list and update training
  so I can manage the list and update training

 Scenario: Going to list training
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    Then I should have 3 trainings
    And I should see "Jack fernandes"

 Scenario: Going to update valid training
    Given one logged in user
    When I visit to employment page with firstname: "nungky" 
    And I follow "Jack fernandes"
    And I fill in "training_person_trained_in" with "Andy"
    And I press "Simpan"
    And I visit to employment page with firstname: "nungky"
    Then I should see "Andy"
    And I should not see "Jack fernandes"

 Scenario: Going to update invalid training
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    And I follow "Jack fernandes"
    And I fill in "training_person_trained_in" with ""
    And I press "Simpan"    
    Then I should see "Pelatih tidak boleh kosong"