FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password 'asdf1234'

    trait :admin do
      admin true
    end
  end
end
