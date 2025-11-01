class Shop < ApplicationRecord
    validates :name, :introduction, presence: true

    has_many :posts
    has_many :shop_sakes, dependent: :destroy
    has_many :sakes, through: :shop_sakes
    has_many :shop_foods, dependent: :destroy
    has_many :foods, through: :shop_foods
    has_many :shop_places, dependent: :destroy
    has_many :likes, dependent: :destroy

    accepts_nested_attributes_for :shop_places

    attr_accessor :sake_names_input, :food_names_input

    def self.ransackable_attributes(auth_object = nil)
        %w[id name introduction created_at updated_at]
    end

    def self.ransackable_associations(auth_object = nil)
        %w[posts sakes foods shop_places]
    end

    # スペース区切りの文字列から酒のタグを更新
    def update_sake_tags(sake_names_string)
        return if sake_names_string.nil?

        # 全角・半角スペースで分割
        sake_names = sake_names_string.split(/[[:space:]]+/).reject(&:blank?)

        # 新しいsakeのIDリストを作成
        new_sake_ids = sake_names.map do |name|
            Sake.find_or_create_by!(name: name).id
        end

        # 既存の関連を完全に置き換え
        self.sake_ids = new_sake_ids
    end

    # スペース区切りの文字列から料理のタグを更新
    def update_food_tags(food_names_string)
        return if food_names_string.nil?

        # 全角・半角スペースで分割
        food_names = food_names_string.split(/[[:space:]]+/).reject(&:blank?)

        # 新しいfoodのIDリストを作成
        new_food_ids = food_names.map do |name|
            Food.find_or_create_by!(name: name).id
        end

        # 既存の関連を完全に置き換え
        self.food_ids = new_food_ids
    end

    # ユーザーがこの店をいいねしているかどうか
    def liked_by?(user)
        likes.exists?(user_id: user.id)
    end
end
