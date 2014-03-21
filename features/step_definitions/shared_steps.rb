Given /^the following users and payments exist$/ do |table|
  @users = []
  table.hashes.each do |hash|
    user = User.where(:email => hash['email']).first || FactoryGirl.create(:user, {'email' => hash['email']} )
    FactoryGirl.create(:payment, hash.except('email').merge('user_id' => user.id) )
    @users << user.reload
  end
end

Given /^I click on "(.*?)"$/ do |button|
  click_button button
end

Then /^I should not see any error messages$/ do
  page.should_not have_css('div #error_explanation')
end

Given /^I should see an error message$/ do
  page.should have_css('div #error_explanation')
end

Given /^I am logged as a[n]* "(.*?)"$/ do |role|
  @user ||= nil
  if @user.nil?
    if role.downcase == 'admin'
      @user = FactoryGirl.create(:admin)
    elsif role.downcase == 'client'
      @user = FactoryGirl.create(:user)
    elsif role.downcase == 'client with credit'
      @user = FactoryGirl.create(:user_with_credit)
    end
  end

  visit new_user_session_path
  fill_in "user_email", :with => @user.email
  fill_in "user_password", :with => @user.password
  click_button "Ingresar"

  if role.downcase == 'admin'
    page.current_path.should == admins_path
  elsif role.downcase == 'client'
    page.current_path.should == clients_path
  end
end

When /^I logoff from the app$/ do
  find('li#sign_out a').click
  page.current_path.should == new_user_session_path
end

When /^I confirm the popup$/ do
  page.driver.browser.accept_js_confirms
end