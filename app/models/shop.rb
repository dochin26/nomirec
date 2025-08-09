class Shop < ApplicationRecord
    validates :name, :introduction, presence: true

    has_many :posts
    has_many :shop_sakes
    has_many :sakes, through: :shop_sakes
    has_many :shop_foods
    has_many :foods, through: :shop_foods

    accepts_nested_attributes_for :shop_sakes, allow_destroy: true
    accepts_nested_attributes_for :shop_foods, allow_destroy: true
    accepts_nested_attributes_for :sakes
    accepts_nested_attributes_for :foods

    before_validation :find_or_assign_existing_sakes
    before_validation :find_or_assign_existing_foods

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
