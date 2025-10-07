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
end
