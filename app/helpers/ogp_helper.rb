module OgpHelper
  # OGP用の画像URLを生成
  def ogp_image_url(post)
    if post.body_image.attached?
      if Rails.env.production?
        # 本番環境: Cloudflare R2の公開URLを使用
        if Rails.application.credentials.dig(:r2, :public_url).present?
          # 公開URLが設定されている場合（画像を直接参照）
          "#{Rails.application.credentials.dig(:r2, :public_url)}/#{post.body_image.key}"
        else
          # polymorphic_urlで生成（署名付きURL）
          begin
            polymorphic_url(post.body_image.variant(resize_to_limit: [ 1200, 630 ]))
          rescue => e
            Rails.logger.error "Error generating image URL: #{e.message}"
            polymorphic_url(post.body_image)
          end
        end
      else
        # 開発環境: ローカルのActive Storage URL
        begin
          polymorphic_url(post.body_image.variant(resize_to_limit: [ 1200, 630 ]))
        rescue => e
          Rails.logger.error "Error generating image URL: #{e.message}"
          polymorphic_url(post.body_image)
        end
      end
    else
      # デフォルト画像のURL
      ActionController::Base.helpers.asset_url("nomireq_logo.jpg")
    end
  end

  # OGPメタタグを設定
  def set_post_meta_tags(post)
    image_url = ogp_image_url(post)

    # デバッグ用ログ
    Rails.logger.info "=== OGP Image URL: #{image_url} ==="

    set_meta_tags(
      title: "#{post.shop.name} - NomireQ",
      description: "特徴的なお酒や料理を共有しよう！ NomireQ",
      og: {
        title: post.shop.name,
        description: "特徴的なお酒や料理を共有しよう！ NomireQ",
        type: "article",
        url: post_url(post),
        image: image_url
      },
      twitter: {
        card: "summary_large_image",
        title: post.shop.name,
        description: "特徴的なお酒や料理を共有しよう！ NomireQ",
        image: image_url
      }
    )
  end
end
