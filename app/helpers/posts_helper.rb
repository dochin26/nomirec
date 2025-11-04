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

    # 常にurl_forを使用（Active StorageがCloudflare R2のURLを自動生成）
    url_for(processed_image)
  end
end
