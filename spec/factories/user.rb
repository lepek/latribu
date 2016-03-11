FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user do
    first_name "John"
    last_name  "Doe"
    phone "3413456789"
    email { generate(:email) }
    password "12345678"

    factory :user_with_credit do
      after(:create) do |user, evaluator|
        create_list(:payment, 1, :user => user)
      end
    end

    factory :admin do
      role_id 1
    end

  end
end
