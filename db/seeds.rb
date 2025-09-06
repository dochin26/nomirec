# Fakerのリセット
Faker::Beer.unique.clear
Faker::Food.unique.clear
Faker::Name.unique.clear
Faker::Address.unique.clear
Faker::Restaurant.unique.clear

# testユーザーを作成
User.create(
    name: "test",
    email: "aaa@aaa.com",
    password: "aaaaaa"
)


# 新規ユーザー２０人を作成
1..20.times do |n|
  name = Faker::Name.unique.name
  email = Faker::Internet.email
  password = "1234qwer"

  User.create(
    name: name,
    email: email,
    password: password
  )
end

# 新規酒・料理を２０個ずつ作成
20.times do |n|
    sake = Faker::Beer.unique.name
    food = Faker::Food.unique.dish
    sake.gsub(" ", "")
    food.gsub(" ", "")

    Sake.create(
        name: sake
    )

    Food.create(
        name: food
    )
end

# 新規店舗２０個、店舗に紐づく酒・料理、投稿を２０個ずつ作成
20.times do |n|
    sake_id = rand(20)
    food_id = rand(20)
    user_id = rand(20)

    Shop.create(
        name: Faker::Restaurant.name,
        introduction: Faker::Lorem.characters(number: 16)
    )

    ShopSake.create(
        shop_id: n,
        sake_id: sake_id
    )

    ShopFood.create(
        shop_id: n,
        food_id: food_id
    )

    ShopPlace.create(
        shop_id: n,
        address: Faker::Address.unique.state
    )

    Post.create(
        user_id: user_id,
        shop_id: n,
        comment: Faker::Restaurant.review
    )
end
