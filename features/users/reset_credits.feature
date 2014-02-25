@reset_credits
Feature: Reset credits
  In order to start a new month
  As the owner of Nahual
  I want to reset my clients unused credits

  Background:
    Given the following shifts exist
      | day       | start_time |
      | monday    | 12:00      |
      | tuesday   | 12:00      |
      | wednesday | 12:00      |
      | thursday  | 12:00      |
      | friday    | 12:00      |
    And the following users and payments exist
      | email       | credit | month    | year |
      | 1@gmail.com | 4      | january  | 2014 |

  Scenario: User use all the credits in the month
    Given Given Today is "Jan 19 2014, 0:00"
    And the user 1@gmail.com has used all the credits
    When I reset the credits
    Then the user 1@gmail.com should have 0 credits

  Scenario: User doesn't use all the credits in the month
    Given Given Today is "Jan 19 2014, 0:00"
    And the user 1@gmail.com has not used all the credits
    When I reset the credits
    Then the user 1@gmail.com should have 0 credits

  Scenario: User use all the credits in the month and pays a new month
    Given Given Today is "Jan 19 2014, 0:00"
    And the user 1@gmail.com has used all the credits
    And the user pays for 4 credits in february
    When I reset the credits
    Then the user 1@gmail.com should have 4 credits

  Scenario: User doesn't use all the credits in the month and pays a new month
    Given Given Today is "Jan 19 2014, 0:00"
    And the user 1@gmail.com has not used all the credits
    And the user pays for 4 credits in february
    When I reset the credits
    Then the user 1@gmail.com should have 4 credits
