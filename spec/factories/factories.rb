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
    credit 0
    factory :admin do
      role_id 1
    end
  end

  factory :shift do
    day "monday"
    start_time "12:00"
    max_attendants "12"
    open_inscription "36"
    close_inscription "6"
    instructor
    discipline
  end

end