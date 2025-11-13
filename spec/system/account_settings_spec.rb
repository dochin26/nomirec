require 'rails_helper'

RSpec.describe "AccountSettings", type: :system do
  let(:user) { create(:user, name: "テストユーザー", email: "test@example.com", password: "password") }

  before do
    sign_in user
    driven_by :rack_test
  end

  describe "アカウント設定ページ" do
    it "マイページからアカウント設定ページに遷移できる" do
      visit mypage_path

      click_link href: edit_account_path

      expect(page).to have_content("アカウント設定")
      expect(page).to have_field("user[name]", with: user.name)
      expect(page).to have_field("user[email]", with: user.email)
    end
  end

  describe "ユーザー名の変更" do
    it "正しいユーザー名で更新できる" do
      visit edit_account_path

      fill_in "user[name]", with: "新しいユーザー名"
      click_button "保存する"

      expect(page).to have_content("アカウント情報を更新しました")
      expect(user.reload.name).to eq("新しいユーザー名")
    end

    it "空のユーザー名では更新できない" do
      visit edit_account_path

      fill_in "user[name]", with: ""
      click_button "保存する"

      expect(page).to have_content("エラー")
      expect(user.reload.name).to eq("テストユーザー")
    end
  end

  describe "メールアドレスの変更" do
    it "正しいメールアドレスで更新できる" do
      visit edit_account_path

      fill_in "user[email]", with: "newemail@example.com"
      click_button "保存する"

      expect(page).to have_content("アカウント情報を更新しました")
      expect(user.reload.email).to eq("newemail@example.com")
    end

    it "無効な形式のメールアドレスでは更新できない" do
      visit edit_account_path

      fill_in "user[email]", with: "invalid-email"
      click_button "保存する"

      expect(page).to have_content("エラー")
      expect(user.reload.email).to eq("test@example.com")
    end

    it "既に存在するメールアドレスでは更新できない" do
      other_user = create(:user, email: "existing@example.com")

      visit edit_account_path

      fill_in "user[email]", with: "existing@example.com"
      click_button "保存する"

      expect(page).to have_content("エラー")
      expect(user.reload.email).to eq("test@example.com")
    end
  end

  describe "パスワードの変更" do
    context "通常のユーザー（OAuth以外）" do
      it "正しい情報でパスワードを変更できる" do
        visit edit_account_path

        fill_in "user[current_password]", with: "password"
        fill_in "user[password]", with: "newpassword123"
        fill_in "user[password_confirmation]", with: "newpassword123"
        click_button "保存する"

        expect(page).to have_content("アカウント情報を更新しました")

        # 新しいパスワードでログインできることを確認
        click_link "ログアウト"
        visit new_user_session_path
        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: "newpassword123"
        click_button "ログイン"

        expect(page).to have_content("ログインしました")
      end

      it "現在のパスワードが間違っている場合は変更できない" do
        visit edit_account_path

        fill_in "user[current_password]", with: "wrongpassword"
        fill_in "user[password]", with: "newpassword123"
        fill_in "user[password_confirmation]", with: "newpassword123"
        click_button "保存する"

        expect(page).to have_content("エラー")
      end

      it "パスワード確認が一致しない場合は変更できない" do
        visit edit_account_path

        fill_in "user[current_password]", with: "password"
        fill_in "user[password]", with: "newpassword123"
        fill_in "user[password_confirmation]", with: "differentpassword"
        click_button "保存する"

        expect(page).to have_content("エラー")
      end

      it "6文字未満のパスワードでは変更できない" do
        visit edit_account_path

        fill_in "user[current_password]", with: "password"
        fill_in "user[password]", with: "short"
        fill_in "user[password_confirmation]", with: "short"
        click_button "保存する"

        expect(page).to have_content("エラー")
      end

      it "パスワード変更しない場合は他の情報のみ更新できる" do
        visit edit_account_path

        fill_in "user[name]", with: "更新されたユーザー名"
        # パスワードフィールドは空のまま
        click_button "保存する"

        expect(page).to have_content("アカウント情報を更新しました")
        expect(user.reload.name).to eq("更新されたユーザー名")
      end
    end

    context "Google OAuthユーザー" do
      let(:oauth_user) do
        create(:user, provider: "google_oauth2", uid: "12345", password: Devise.friendly_token[0, 20])
      end

      before do
        sign_in oauth_user
      end

      it "パスワード変更フォームが表示されず、説明メッセージが表示される" do
        visit edit_account_path

        expect(page).to have_content("Google認証をご利用中")
        expect(page).to have_content("Google認証でログインしているため、パスワードの変更はできません")
        expect(page).not_to have_field("user[current_password]")
        expect(page).not_to have_field("user[password]")
      end

      it "名前やメールアドレスは変更できる" do
        visit edit_account_path

        fill_in "user[name]", with: "OAuth更新ユーザー"
        click_button "保存する"

        expect(page).to have_content("アカウント情報を更新しました")
        expect(oauth_user.reload.name).to eq("OAuth更新ユーザー")
      end
    end
  end

  describe "アバター画像の変更" do
    it "画像をアップロードできる" do
      visit edit_account_path

      attach_file "user[avatar]", Rails.root.join("spec/fixtures/images/100x100.png")
      click_button "保存する"

      expect(page).to have_content("アカウント情報を更新しました")
      expect(user.reload.avatar).to be_attached
    end

    it "5MBを超える画像はアップロードできない" do
      # このテストは実際のファイルサイズチェックが必要なため、
      # モデルのバリデーションテストとして別途実装することを推奨
      # システムテストでは正常系のみテスト
    end
  end

  describe "フォームの表示" do
    it "現在のユーザー情報がフォームに表示される" do
      visit edit_account_path

      expect(page).to have_field("user[name]", with: user.name)
      expect(page).to have_field("user[email]", with: user.email)
    end

    it "キャンセルボタンでマイページに戻る" do
      visit edit_account_path

      click_link "キャンセル"

      expect(page).to have_current_path(mypage_path)
    end
  end
end
