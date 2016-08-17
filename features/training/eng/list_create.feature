Feature: List and create Training
  In Order to see list and create training
  As admin
  I want to view list and create training
  so I can manage the list and create training

 Scenario: Going to list training
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    Then I should have 3 trainings

Scenario: Going to create valid training
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    And I follow "popup_add_training"
    And I fill in "training_person_trained_in" with "Daniel asmandar"
    And I fill in "training_training_start" with "01/12/2011"
    And I fill in "training_training_end" with "31/12/2011"
    And I press "Simpan"
    And I visit to employment page with firstname: "nungky"
    Then I should have 4 trainings
    And I should see "Daniel asmandar"

Scenario: Going to create invalid training
    Given one logged in user
    When I visit to employment page with firstname: "nungky"
    And I follow "popup_add_training"
    And I fill in "training_person_trained_in" with ""
    And I fill in "training_training_start" with ""
    And I fill in "training_training_end" with ""
    And I press "Simpan"    
    Then I should see "Tanggal selesai tidak boleh kosong"
    And I should see "Tanggal mulai tidak boleh kosong"
    And I should see "Pelatih tidak boleh kosong"