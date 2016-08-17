Feature: User Homepage
  In order to access the homapage
  As a signed in user
  I need to see the homepage

  Scenario: Signed User Accessing Dashboard Page
    Given one logged in user
    When I go to the dashboard_index page
    Then I should see "Dashboard"