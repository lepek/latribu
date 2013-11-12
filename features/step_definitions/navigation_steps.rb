Given /^I am in the registration page$/ do
  visit new_user_registration_path
end

Given /^I am in the inscriptions page$/ do
  visit clients_path
  click_on "Próximas clases"
end