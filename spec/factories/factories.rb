def get_discipline
  Discipline.where(:name => 'Crossfit').first || FactoryGirl.create(:discipline)
end

FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :instructor do
    first_name "Fede"
    last_name "Adell"
  end

  factory :discipline do
    name "Crossfit"
  end

  factory :user do
    first_name "John"
    last_name  "Doe"
    phone "3413456789"
    email { generate(:email) }
    password "12345678"
    last_reset_date '2014-01-01 23:59:59'
    factory :user_with_credit do
      after(:create) do |user, evaluator|
        create_list(:payment, 1, :user => user)
      end
    end
    factory :admin do
      role_id 1
    end
    after(:create) do |user, evaluator|
      user.disciplines << get_discipline
    end
  end

  factory :payment do
    credit 1
    month_year { Chronic.parse("now") }
    amount 200
    user
  end

  factory :shift do
    day "monday"
    start_time "12:00"
    max_attendants "12"
    open_inscription "999999"
    close_inscription "0"
    cancel_inscription "2"
    instructor
    discipline { |shift| get_discipline }
  end

end