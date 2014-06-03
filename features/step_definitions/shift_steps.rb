Given /^the following shifts exist$/ do |table|
  @classes = []
  table.hashes.each do |hash|
    shift = FactoryGirl.build(:shift, hash)
    shift.save
    @classes << shift
  end
end

Given /^Today is "(.*?)"$/ do |date|
  Timecop.freeze(Time.parse(date))
end

Then /^I should see the next class on "(.*?)"$/ do |next_class|
  find('#inscriptions-table').should have_content(next_class)
end

Then /^I should not see the next class on "(.*?)"$/ do |next_class|
  find('table#inscriptions-table > tbody > tr:first-child > td:first-child').should_not have_content(next_class)
end

Then /^I should see the class as "(.*?)"$/ do |status|
  find('table#inscriptions-table > tbody > tr:first-child > td:nth-child(4)').should have_content(status)
end

Given /^I have "(.*?)" credits$/ do |credit|
  @user.credit = 0
  @user.save!
  Payment.create(:user_id => @user.id, :month => Chronic.parse("now").strftime('%B').downcase, :amount => 200, :credit => credit)
  @user.reload
end

Then /^I should not be able to enroll$/ do
  find('table#inscriptions-table > tbody > tr:first-child > td:nth-child(6)').should_not have_css('input[value="Anotarse"]')
end

Then /^I should be able to enroll$/ do
  find('table#inscriptions-table > tbody > tr:first-child > td:nth-child(6)').should have_css('input[value="Anotarse"]')
end

Then /^The class is full$/ do
  @class = @classes.first
  (1..@class.max_attendants.to_i).each do |i|
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:payment, {'user_id' => user.id, 'month_year' => Chronic.parse("now")})
    user.reload
    @class.enroll_next_shift user
  end
  @class.errors.count.should == 0
  @class.next_fixed_shift_users.count.should == @class.max_attendants
  @class.status.should == Shift::STATUS[:full]
end

Then /^I enroll into the class$/ do
  credit_before = @user.credit
  find('li#credit').should have_content(credit_before)
  click_on "Anotarse"
  find('li#credit').should have_content(credit_before.to_i - 1)
  find('table#inscriptions-table > tbody > tr:first-child > td:nth-child(6)').should have_css('input[value="Liberar"]')
  find('table#inscriptions-table > tbody > tr:first-child > td:nth-child(3)').should have_content('1')
end

Then /^I should have "(.*?)" credits$/ do |credit|
  find('li#credit').should have_content(credit)
end