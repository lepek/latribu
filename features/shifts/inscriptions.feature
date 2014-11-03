@inscriptions
Feature: Client inscriptions
  In order to go to a class
  As a client
  I want to sign up to an open class

  Background:
    Given I am logged as a "client with credit"
    And the following shifts exist
      | day    | start_time | max_attendants | open_inscription | close_inscription |
      | monday | 21:00      | 4              | 12               | 3                 |

  Scenario: Today is Tuesday, November 12th and the next class is Monday, November 18th 21:00 hs
    Given Today is "Nov 12 2013, 0:00"
    And I am in the inscriptions page
    Then I should see the next class on "lun, 18 de nov 21:00 hs."

  Scenario: The class does not show up because it is in the past
    Given Today is "Nov 19 2013, 0:00"
    And I am in the inscriptions page
    Then I should not see the next class on "lun, 18 de nov 21:00 hs."
    And I should see the next class on "lun, 25 de nov 21:00 hs."

  Scenario: The class is unavailable because it is not opened yet
    Given Today is "Nov 18 2013, 8:00"
    And I am in the inscriptions page
    Then I should see the class as "Cerrada"

  Scenario: The class is available because it is open
    Given Today is "Nov 18 2013, 10:00"
    And I am in the inscriptions page
    Then I should see the class as "Abierta"

  Scenario: The class is unavailable because I don't have credits
    Given Today is "Nov 18 2013, 10:00"
    And I have "0" credits

  Scenario: The class is available and I can use it
    Given Today is "Nov 18 2013, 10:00"
    And I am in the inscriptions page
    Then I should see the class as "Abierta"
    Then I should be able to enroll

  Scenario: The class is unavailable because it is completed
    Given Today is "Nov 18 2013, 10:00"
    And The class is full
    And I am in the inscriptions page
    Then I should see the class as "Completa"
    Then I should not be able to enroll

  Scenario: I can enroll myself into a class and my credit is updated
    Given Today is "Nov 18 2013, 10:00"
    And I am in the inscriptions page
    Then I enroll into the class




