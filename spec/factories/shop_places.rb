FactoryBot.define do
  factory :shop_place do
    association :shop
    latitude { nil }
    longitude { nil }
    address { "東京都西東京市" }
  end
end
