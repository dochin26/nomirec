class Shop < ApplicationRecord
    validates :name, :introduction, presence: true

    has_many :posts
    has_many :shop_sakes, dependent: :destroy
    has_many :sakes, through: :shop_sakes
    has_many :shop_foods, dependent: :destroy
    has_many :foods, through: :shop_foods
    has_many :shop_places, dependent: :destroy

    accepts_nested_attributes_for :shop_sakes, allow_destroy: true
    accepts_nested_attributes_for :shop_foods, allow_destroy: true
    accepts_nested_attributes_for :sakes
    accepts_nested_attributes_for :foods
    accepts_nested_attributes_for :shop_places

    before_validation :find_or_assign_existing_sakes
    before_validation :find_or_assign_existing_foods

    def self.ransackable_attributes(auth_object = nil)
        %w[id name introduction created_at updated_at]
    end

    def self.ransackable_associations(auth_object = nil)
        %w[posts sakes foods]
    end

    private

    def find_or_assign_existing_sakes
    self.sakes = sakes.map do |sake|
        if sake.name.present?
        Sake.find_by(name: sake.name) || sake
        else
        sake
        end
    end
    end

    def find_or_assign_existing_foods
    self.foods = foods.map do |food|
        if food.name.present?
        Food.find_by(name: food.name) || food
        else
        food
        end
    end
    end
end
