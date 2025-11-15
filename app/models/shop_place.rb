class ShopPlace < ApplicationRecord
  belongs_to :shop

  def self.ransackable_attributes(auth_object = nil)
    %w[id address created_at updated_at shop_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[shop]
  end
end
