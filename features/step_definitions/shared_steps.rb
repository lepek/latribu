Given /^I click on "(.*?)"$/ do |button|
  click_button button
end

Then /^I should not see any error messages$/ do
  page.should_not have_css('div #error_explanation')
end

Given /^I should see an error message$/ do
  page.should have_css('div #error_explanation')
end