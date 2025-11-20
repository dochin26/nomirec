class ShopPlace < ApplicationRecord
  belongs_to :shop

  # 緯度経度のバリデーション（カスタムバリデーションで1つのエラーのみ表示）
  validate :location_must_be_set

  # 緯度経度が変更された場合、逆ジオコーディングで住所を取得
  before_save :reverse_geocode_address, if: :coordinates_changed?

  def self.ransackable_attributes(auth_object = nil)
    %w[id address created_at updated_at shop_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[shop]
  end

  private

  # 緯度経度が設定されているかチェック
  def location_must_be_set
    if latitude.blank? || longitude.blank?
      errors.add(:base, I18n.t("activerecord.errors.models.shop_place.location_required"))
    end
  end

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
