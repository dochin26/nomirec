FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "testuser#{n}" }
    sequence(:email) { |n| "test#{n}@test.com" }
    password { "password" }
  end
end
