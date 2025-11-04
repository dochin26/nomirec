module PostsHelper
  # post.body_image の URL を環境に応じて返す（バリアント対応）
  def image_url_for(image, size: :medium)
    return unless image.attached?

    # バリアントを使用する場合
    processed_image = if image.variable?
      image.variant(size)
    else
      image
    end

    if Rails.env.production? && Rails.application.credentials.dig(:r2, :public_url).present?
      # 本番環境では R2 の URL を返す
      if image.variable?
        # バリアントの場合はActiveStorageのURLを使用（R2でも処理される）
        url_for(processed_image)
      else
        "#{Rails.application.credentials.dig(:r2, :public_url)}/#{image.key}"
      end
    else
      # 開発環境や R2 URL がない場合は ActiveStorage の url_for を使用
      url_for(processed_image)
    end
  end
end
