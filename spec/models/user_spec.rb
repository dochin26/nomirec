require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    describe "name" do
      it "20文字以下の場合は有効である" do
        user = build(:user, name: "あ" * 20)
        expect(user).to be_valid
      end

      it "21文字以上の場合は無効である" do
        user = build(:user, name: "あ" * 21)
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("は20文字以内で入力してください")
      end

      it "空の場合は無効である" do
        user = build(:user, name: "")
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("を入力してください")
      end

      it "nilの場合は無効である" do
        user = build(:user, name: nil)
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("を入力してください")
      end
    end

    describe "email" do
      it "一意である必要がある" do
        create(:user, email: "test@example.com")
        user = build(:user, email: "test@example.com")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("はすでに存在します")
      end

      it "空の場合は無効である" do
        user = build(:user, email: "")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("を入力してください")
      end

      it "正しい形式のメールアドレスである必要がある" do
        user = build(:user, email: "invalid_email")
        expect(user).not_to be_valid
      end
    end

    describe "password" do
      it "6文字以上の場合は有効である" do
        user = build(:user, password: "password123", password_confirmation: "password123")
        expect(user).to be_valid
      end

      it "5文字以下の場合は無効である" do
        user = build(:user, password: "pass", password_confirmation: "pass")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("は6文字以上で入力してください")
      end

      it "確認用パスワードと一致する必要がある" do
        user = build(:user, password: "password123", password_confirmation: "different")
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("とパスワードの入力が一致しません")
      end
    end
  end

  describe "アソシエーション" do
    it "複数の投稿を持つことができる" do
      association = described_class.reflect_on_association(:posts)
      expect(association.macro).to eq(:has_many)
    end

    it "複数のいいねを持つことができる" do
      association = described_class.reflect_on_association(:likes)
      expect(association.macro).to eq(:has_many)
    end

    it "複数のコメントを持つことができる" do
      association = described_class.reflect_on_association(:comments)
      expect(association.macro).to eq(:has_many)
    end

    it "ユーザーが削除されると関連する投稿も削除される" do
      user = create(:user)
      create(:post, user: user)

      expect { user.destroy }.to change { Post.count }.by(-1)
    end
  end

  describe "OAuth認証" do
    let(:auth_data) do
      OmniAuth::AuthHash.new({
        provider: "google_oauth2",
        uid: "12345",
        info: {
          name: "Test User",
          email: "oauth@example.com"
        }
      })
    end

    it "新しいユーザーを作成できる" do
      expect {
        User.from_omniauth(auth_data)
      }.to change { User.count }.by(1)

      user = User.last
      expect(user.name).to eq("Test User")
      expect(user.email).to eq("oauth@example.com")
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("12345")
    end

    it "既存のユーザーが存在する場合は新規作成しない" do
      create(:user, email: "oauth@example.com")

      expect {
        User.from_omniauth(auth_data)
      }.not_to change { User.count }
    end
  end

  describe "アバター画像" do
    it "アバター画像を添付できる" do
      user = create(:user)
      user.avatar.attach(
        io: File.open(Rails.root.join("spec/fixtures/images/100x100.png")),
        filename: "avatar.png",
        content_type: "image/png"
      )

      expect(user.avatar).to be_attached
    end
  end
end
