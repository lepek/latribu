@sign_up
Feature: Client sign up
  In order to use the application
  As the owner of Nahual
  I want them to be in my client list

  Scenario: Successful registration
    Given I am in the registration page
    When I fill all the registration form
    And I click on "Registrarse"
    Then I should not see any error messages
    And I should be registered

  Scenario: Registration without first name
    Given I am in the registration page
    When I fill all the registration form without the "first_name"
    And I click on "Registrarse"
    Then I should see an error message
    And I should not be registered

  Scenario: Registration without last name
    Given I am in the registration page
    When I fill all the registration form without the "last_name"
    And I click on "Registrarse"
    Then I should see an error message
    And I should not be registered

  Scenario: Registration without phone
    Given I am in the registration page
    When I fill all the registration form without the "phone"
    And I click on "Registrarse"
    Then I should see an error message
    And I should not be registered

  Scenario: Registration without email
    Given I am in the registration page
    When I fill all the registration form without the "email"
    And I click on "Registrarse"
    Then I should see an error message
    And I should not be registered

  Scenario: Registration without password
    Given I am in the registration page
    When I fill all the registration form without the "password"
    And I click on "Registrarse"
    Then I should see an error message
    And I should not be registered

  Scenario: Registration without password confirmation
    Given I am in the registration page
    When I fill all the registration form without the "password_confirmation"
    And I click on "Registrarse"
    Then I should see an error message
    And I should not be registered