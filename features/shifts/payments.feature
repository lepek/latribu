@payments
Feature: Client payments
  In order to let clients go to a class
  As an admin
  I want to register a payment

  Background:
    Given I am logged as an "admin"
    And the following clients exist
      | first_name | last_name | phone | email            |
      | Martin     | Bianculli | 12321 | martin@gmail.com |

  Scenario: Admin makes a payment
    Given Today is "Nov 21 2013, 10:00"
    And I am in the payment page
    When I add a payment for "Martin Bianculli" in "noviembre" for an amount of "200" and "5" credits
    And I click on "Guardar"
    Then I should see the following in the payments list
      | cliente          | fecha_ultimo_pago                 | monto | credito |
      | Martin Bianculli | jueves, 21 de noviembre 10:00 hs. | 200   | 5       |
