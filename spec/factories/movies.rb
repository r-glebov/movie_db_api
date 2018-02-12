FactoryBot.define do
  factory :movie do
    title { Faker::RickAndMorty.unique.quote }
    description 'Description'
    rating 1
  end
end
