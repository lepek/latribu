FactoryGirl.define do

  factory :payment do
    credit 10
    month_year { Chronic.parse("now") }
    amount 200
    user
  end

end
