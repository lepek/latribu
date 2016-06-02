FactoryGirl.define do

  factory :payment do
    credit 10
    month_year { Chronic.parse("1 this month") }
    credit_start_date { Chronic.parse("1 this month") }
    credit_end_date { Chronic.parse("1 next month") }
    amount 200
    user
  end

end
