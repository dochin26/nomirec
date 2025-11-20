FactoryBot.define do
  factory :shop_place do
    association :shop
    latitude { 35.6812362 }
    longitude { 139.7671248 }
    address { "東京都西東京市" }
  end
end
