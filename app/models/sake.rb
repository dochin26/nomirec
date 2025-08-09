class Sake < ApplicationRecord
    validates :name, presence: true

    has_many :shop_sakes
    has_many :shops, through: :shop_sakes
end
