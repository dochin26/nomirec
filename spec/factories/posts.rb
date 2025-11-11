FactoryBot.define do
  factory :post do
    association :user
    association :shop
  end
end
