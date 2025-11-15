class Post < ApplicationRecord
    include ImageValidatable

    belongs_to  :shop
    belongs_to  :user
    has_many    :comments, dependent: :destroy

    accepts_nested_attributes_for :shop

    after_destroy :destroy_shop

  has_one_attached :body_image do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 200, 200 ], preprocessed: true
    attachable.variant :medium, resize_to_limit: [ 800, 600 ], preprocessed: true
    attachable.variant :large, resize_to_limit: [ 1200, 900 ], preprocessed: true
  end

  validates_image_attachment :body_image,
                              max_size: 10,
                              allowed_types: [ "image/jpeg", "image/jpg", "image/png", "image/webp", "image/gif" ]

    def self.ransackable_attributes(auth_object = nil)
        %w[id created_at updated_at shop_id user_id]
    end

    def self.ransackable_associations(auth_object = nil)
        %w[shop user]
    end

    # オートコンプリート検索
    def self.search_autocomplete(query)
        search_query = "%#{query}%"
        results = [
            search_shops(search_query),
            search_sakes(search_query),
            search_foods(search_query),
            search_addresses(search_query)
        ].flatten

        results.uniq { |r| [ r[:type], r[:name], r[:address] ] }.first(10)
    end

    def self.search_shops(query)
        Shop.joins(:posts)
            .where("shops.name LIKE ?", query)
            .select("DISTINCT shops.id, shops.name")
            .order("shops.name ASC")
            .limit(10)
            .map { |shop| { type: "shop", name: shop.name, value: shop.name } }
    end

    def self.search_sakes(query)
        Sake.where("sakes.name LIKE ?", query)
            .includes(shops: [ :shop_places, :posts ])
            .order("sakes.name ASC")
            .limit(10)
            .flat_map { |sake| build_item_results(sake, "sake") }
    end

    def self.search_foods(query)
        Food.where("foods.name LIKE ?", query)
            .includes(shops: [ :shop_places, :posts ])
            .order("foods.name ASC")
            .limit(10)
            .flat_map { |food| build_item_results(food, "food") }
    end

    def self.search_addresses(query)
        ShopPlace.joins(shop: :posts)
            .where("shop_places.address LIKE ?", query)
            .includes(:shop)
            .select("DISTINCT shop_places.id, shop_places.address, shop_places.shop_id")
            .order("shop_places.address ASC")
            .limit(10)
            .map { |place| { type: "address", name: place.shop.name, address: place.address, value: place.address } }
    end

    def self.build_item_results(item, type)
        item.shops.flat_map do |shop|
            next [] unless shop.posts.any?

            shop.shop_places.map do |place|
                {
                    type: type,
                    name: shop.name,
                    address: place.address,
                    value: item.name,
                    "#{type}_name".to_sym => item.name
                }
            end
        end.compact
    end

    private

    def destroy_shop
        shop.destroy if shop && shop.posts.empty?
    end
end
