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
        update_tags(sake_names_string, :sakes)
    end

    # スペース区切りの文字列から料理のタグを更新
    def update_food_tags(food_names_string)
        update_tags(food_names_string, :foods)
    end

    # ユーザーがこの店をいいねしているかどうか
    def liked_by?(user)
        likes.exists?(user_id: user.id)
    end

    private

    # スペース区切りの文字列からタグを更新する共通メソッド
    def update_tags(tags_string, association_name)
        return if tags_string.nil?

        # 全角・半角スペースで分割
        tag_names = tags_string.split(/[[:space:]]+/).reject(&:blank?)

        # モデルクラスを取得 (例: :sakes -> Sake)
        model_class = association_name.to_s.singularize.classify.constantize

        # 新しいタグのIDリストを作成
        new_tag_ids = tag_names.map do |name|
            model_class.find_or_create_by!(name: name).id
        end

        # 既存の関連を完全に置き換え
        self.send("#{association_name.to_s.singularize}_ids=", new_tag_ids)
    end
end
