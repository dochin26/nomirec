class Post < ApplicationRecord
    validates :comment, presence: true

    belongs_to :shop
    belongs_to :user

    accepts_nested_attributes_for :shop
end
