class Post < ApplicationRecord
    validates :comment, presence: true

    belongs_to :shop
    belongs_to :user

    accepts_nested_attributes_for :shop

    after_destroy :destroy_shop

    def self.ransackable_attributes(auth_object = nil)
        %w[id created_at updated_at shop_id user_id]
    end

    def self.ransackable_associations(auth_object = nil)
        %w[shop user]
    end

    private

    def destroy_shop
        shop.destroy if shop && shop.posts.empty?
    end
end
