module PostsHelper
  # post.body_image の URL を環境に応じて返す
  def image_url_for(image)
    return unless image.attached?

    if Rails.env.production? && Rails.application.credentials.r2[:public_url].present?
      # 本番環境では R2 の URL を返す
      "#{Rails.application.credentials.r2[:public_url]}/#{image.key}"
    else
      # 開発環境や R2 URL がない場合は ActiveStorage の url_for を使用
      url_for(image)
    end
  end
end
