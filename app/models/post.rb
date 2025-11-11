class Post < ApplicationRecord
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

  validate :acceptable_image

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

    def acceptable_image
        return unless body_image.attached?

        unless body_image.byte_size <= 10.megabytes
            errors.add(:body_image, "は10MB以下にしてください")
        end

        acceptable_types = [ "image/jpeg", "image/jpg", "image/png", "image/webp", "image/gif" ]
        unless acceptable_types.include?(body_image.content_type)
            errors.add(:body_image, "はJPEG、PNG、WebP、GIF形式で登録してください")
        end
    end
end
