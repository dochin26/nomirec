FactoryBot.define do
  factory :comment do
    association :user
    association :post
    body { "これは素晴らしいお店ですね！" }
  end
end
