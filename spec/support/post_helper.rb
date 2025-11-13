module PostHelper
  def create_post_with_relations(user:)
    shop = create(:shop)   # factoryのデフォルト値を利用
    sake = create(:sake)
    food = create(:food)

    create(:shop_sake, shop: shop, sake: sake)
    create(:shop_food, shop: shop, food: food)
    create(:shop_place, shop: shop)
    create(:post, user: user, shop: shop)
  end
end

RSpec.configure do |config|
  config.include PostHelper
end
