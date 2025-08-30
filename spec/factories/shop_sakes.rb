FactoryBot.define do
  factory :shop_sake do
    association :shop
    association :sake
  end
end
