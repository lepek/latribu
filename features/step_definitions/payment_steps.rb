Given /^I add a payment for "(.*?)" in "(.*?)" "(.*?)" for an amount of "(.*?)" and "(.*?)" credits$/ do |user, month, year, amount, credit|
  select(user, :from => 'Cliente')
  select(month, :from => 'payment_month')
  select(year, :from => 'payment_year')
  fill_in "Monto", :with => amount
  fill_in "Crédito", :with => credit
end

Then /^I should see the following in the payments list$/ do |table|
  table.hashes.each do |hash|
    hash.each do |key, value|
      find('table#payments-table').should have_content(value)
    end
  end
end