class ShopPlace < ApplicationRecord
  belongs_to :shop

  # 緯度経度が変更された場合、逆ジオコーディングで住所を取得
  before_save :reverse_geocode_address, if: :coordinates_changed?

  def self.ransackable_attributes(auth_object = nil)
    %w[id address created_at updated_at shop_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[shop]
  end

  private

  # 緯度経度が変更されたかチェック
  def coordinates_changed?
    latitude_changed? || longitude_changed?
  end

  # 緯度経度から住所を取得して保存
  def reverse_geocode_address
    return unless latitude.present? && longitude.present?

    results = Geocoder.search([ latitude, longitude ])
    if results.present?
      self.address = results.first.address
    end
  end
end
