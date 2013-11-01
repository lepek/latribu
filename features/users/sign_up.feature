@sign_up
Feature: Client sign up
  In order to use the application
  As the owner of Nahual
  I want them to be in my client list

  Scenario: Successful registration
    Given I am in the registration page
    When I fill all the registration form
    And I click on "Guardar"
    Then I should not see any error messages
    And I should be registered

