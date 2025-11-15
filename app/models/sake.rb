class Sake < ApplicationRecord
  validates :name, presence: true

  has_many :shop_sakes
  has_many :shops, through: :shop_sakes

  def self.ransackable_attributes(auth_object = nil)
    %w[id name created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[shops]
  end
end
