FactoryBot.define do
  factory :post do
    association :user
    association :shop
    comment { Faker::Restaurant.review }
  end
end
