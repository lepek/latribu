FactoryGirl.define do

  factory :payment do
    credit 10
    month_year { Chronic.parse("1 this month") }
    amount 200
    user
  end

end
