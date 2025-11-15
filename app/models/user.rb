class User < ApplicationRecord
  include ImageValidatable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
        :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_one_attached :avatar

  validates :name, presence: true, length: { maximum: 20 }
  validates_image_attachment :avatar,
                              max_size: ImageUpload::AVATAR_MAX_SIZE_MB,
                              allowed_types: ImageUpload::AVATAR_ALLOWED_TYPES

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
end
