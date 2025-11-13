require 'rails_helper'

RSpec.describe "UserAuthentication", type: :system do
  let(:user) { create(:user) }

  it "ユーザー登録ができる" do
    visit new_user_registration_path
    fill_in "名前", with: "testuser"
    fill_in "メールアドレス", with: "newuser@example.com"
    fill_in "パスワード", with: "password"
    fill_in "パスワード確認", with: "password"
    click_button "新規登録"

    expect(page).to have_content("アカウント登録が完了しました。") # Deviseのflashメッセージ
  end

  it "ログインできる" do
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    click_button "ログイン"

    expect(page).to have_content("ログインしました。")
  end

  it "ログアウトできる" do
    # ログインしておく
    sign_in user
    visit root_path
    click_link "ログアウト" # ナビゲーションにあるリンク名に合わせて修正

    expect(page).to have_content("ログアウトしました。")
  end

  it "Google認証が成功する" do
    # OmniAuthのモック設定をテスト実行前に行う
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: '12345abcde',
      info: {
        email: 'john@example.com',
        name: 'John Doe'
      }
    })

    # Railsのenv_configにも設定
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

    visit new_user_session_path
    click_button('Googleでログイン')
    expect(page).to have_content('Googleアカウントでログインしました。')
  end
end
