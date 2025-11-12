class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
        :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_one_attached :avatar

  validate :acceptable_avatar

  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.provider = auth.provider
      user.uid = auth.uid
      # パスワードは自動生成（OAuth認証時は不要）
      user.password = Devise.friendly_token[0, 20]
    end
  end

  private

  def acceptable_avatar
    return unless avatar.attached?

    unless avatar.byte_size <= 5.megabytes
      errors.add(:avatar, "は5MB以下にしてください")
    end

    acceptable_types = [ "image/jpeg", "image/jpg", "image/png", "image/webp" ]
    unless acceptable_types.include?(avatar.content_type)
      errors.add(:avatar, "はJPEG、PNG、WebP形式で登録してください")
    end
  end
end
