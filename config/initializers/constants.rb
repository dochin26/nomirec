# アプリケーション全体で使用する定数

# 画像アップロードの設定
module ImageUpload
  # ユーザーアバター用
  AVATAR_MAX_SIZE_MB = 5
  AVATAR_ALLOWED_TYPES = %w[image/jpeg image/jpg image/png image/webp].freeze

  # 投稿画像用
  POST_IMAGE_MAX_SIZE_MB = 10
  POST_IMAGE_ALLOWED_TYPES = %w[image/jpeg image/jpg image/png image/webp image/gif].freeze
end
