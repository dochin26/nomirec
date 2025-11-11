require 'rails_helper'

RSpec.describe "Posts", type: :system do
  let(:user) { create(:user) }

  it "掲示板の作成ができる" do
    sign_in user
    visit new_post_path
    fill_in "店名", with: "ラーメン二郎亀戸店"
    fill_in "説明", with: "ちいかわ公認の二郎で、女性助手がいます。豚も大ぶりで1枚100円で追加可能。"
    fill_in "酒名（複数の場合はスペース区切り）", with: "アサヒビール"
    fill_in "料理名（複数の場合はスペース区切り）", with: "小ラーメン"
    click_button "投稿する"

    expect(page).to have_content("投稿を作成しました。")
  end

  it "店名の検索ができる" do
    sign_in user

    create_post_with_relations(user: user)

    # 検索パラメータを含むURLに直接アクセス
    visit posts_path(q: { shop_name_or_shop_sakes_name_or_shop_foods_name_or_shop_shop_places_address_cont: "ラーメン二郎" })

    expect(page).to have_content("市川海老蔵似のイケメン店主。豚ポタスープが特徴。")
  end

  it "酒名の検索ができる" do
    sign_in user

    create_post_with_relations(user: user)

    # 検索パラメータを含むURLに直接アクセス
    visit posts_path(q: { shop_name_or_shop_sakes_name_or_shop_foods_name_or_shop_shop_places_address_cont: "キリンビール" })

    expect(page).to have_content("ラーメン二郎ひばりヶ丘店")
  end

  it "料理名の検索ができる" do
    sign_in user

    create_post_with_relations(user: user)

    # 検索パラメータを含むURLに直接アクセス
    visit posts_path(q: { shop_name_or_shop_sakes_name_or_shop_foods_name_or_shop_shop_places_address_cont: "ラーメン" })

    expect(page).to have_content("キリンビール")
  end
end
