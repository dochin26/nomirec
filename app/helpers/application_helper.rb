module ApplicationHelper
  IMAGE_SIZES = {
    thumbnail: [ 150, 150 ],
    small: [ 300, 200 ],
    medium: [ 600, 400 ],
    large: [ 1200, 800 ]
  }.freeze

  def image_url_for(image, options = {})
    return unless image.attached?

    if Rails.env.production? && Rails.application.credentials.dig(:r2, :public_url).present?
      # 本番環境ではvariantを使わずオリジナル画像のURLを返す
      # R2のパブリックURLを使用
      "#{Rails.application.credentials.r2[:public_url]}/#{image.key}"
    else
      # 開発環境ではvariantを適用
      processed_image = apply_size_variant(image, options[:size])
      url_for(processed_image)
    end
  end

  private

  def apply_size_variant(image, size)
    return image unless size && IMAGE_SIZES[size]

    dimensions = IMAGE_SIZES[size]
    image.variant(resize_to_limit: dimensions)
  end
end
