module PostsHelper
  # image_url_for method is now in ApplicationHelper

  # 投稿の画像URLを取得（画像がない場合はデフォルト画像を返す）
  def post_image_url(post, size: :medium)
    if post.body_image.attached?
      image_url_for(post.body_image, size: size)
    else
      asset_path("nomireq_logo.jpg")
    end
  end
end
