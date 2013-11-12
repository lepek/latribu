Given /^I click on "(.*?)"$/ do |button|
  click_button button
end

Then /^I should not see any error messages$/ do
  page.should_not have_css('div #error_explanation')
end

Given /^I should see an error message$/ do
  page.should have_css('div #error_explanation')
end

Given /^I am logged as a client$/ do
  @user = FactoryGirl.create(:user)
  visit new_user_session_path
  fill_in "user_email", :with => @user.email
  fill_in "user_password", :with => @user.password
  click_button "Ingresar"
  page.current_path.should == clients_path
end