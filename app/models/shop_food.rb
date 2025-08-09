class ShopFood < ApplicationRecord
  belongs_to :shop
  belongs_to :food
end
