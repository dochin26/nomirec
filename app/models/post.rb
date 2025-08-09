class Post < ApplicationRecord
    validates :comment, presence: true

    belongs_to :shop
    belongs_to :user

    accepts_nested_attributes_for :shop

    after_destroy :destroy_shop

    private

    def destroy_shop
        shop.destroy if shop && shop.posts.empty?
    end
end
