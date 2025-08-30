FactoryBot.define do
  factory :shop_food do
    association :shop
    association :food
  end
end
