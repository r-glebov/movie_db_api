FactoryBot.define do
  factory :movie do
    title { Faker::RickAndMorty.unique.quote }
    description 'Description'
    rating 1

    trait :rating_5 do
      rating 5
    end

    trait :rating_4 do
      rating 4
    end
  end
end
