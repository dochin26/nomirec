class Food < ApplicationRecord
    validates :name, presence: true

    has_many :shop_foods
    has_many :shops, through: :shop_foods
end
