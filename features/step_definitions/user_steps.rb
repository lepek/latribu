Given /^I fill all the registration form$/ do
  fill_in "user_first_name", :with => 'Martin'
  fill_in "user_last_name", :with => 'Luis'
  fill_in "user_phone", :with => '341-3456789'
  fill_in "user_email", :with => 'martin@gmail.com'
  fill_in "user_password", :with => 'contraseña'
  fill_in "user_password_confirmation", :with => 'contraseña'
end

Then /^I should be registered$/ do
  users = User.where(:email => 'martin@gmail.com')
  users.count.should == 1
  user = users.first
  user.first_name.should  == 'Martin'
  user.last_name.should == 'Luis'
  user.phone.should == '341-3456789'
  user.role_id == 2
  user.role == 'Cliente'
  user.email.should_not be_empty
end