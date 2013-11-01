Given /^I click on "(.*?)"$/ do |button|
  click_button button
end

Then /^I should not see any error messages$/ do
  page.should_not have_css('div #error_explanation')
end