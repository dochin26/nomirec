require 'rails_helper'

RSpec.describe "Posts", type: :system do
  let(:user) { create(:user) }

  it "掲示板の作成ができる" do
    sign_in user
    visit new_post_path
    fill_in "店名", with: "ラーメン二郎亀戸店"
    fill_in "説明", with: "ちいかわ公認の二郎で、女性助手がいます。豚も大ぶりで1枚100円で追加可能。"
    fill_in "酒名", with: "アサヒビール"
    fill_in "料理名", with: "小ラーメン"
    fill_in "コメント", with: "盛りがよくて、値段もリーズナブル。脂多めにすると、かなりコッテリになるので要注意です。"
    click_button "投稿する"

    expect(page).to have_content("投稿を作成しました。")
  end

  it "店名の検索ができる" do
    sign_in user

    create_post_with_relations(user: user)

    visit posts_path
    fill_in "q_shop_name_or_shop_sakes_name_or_shop_foods_name_or_shop_shop_places_address_cont", with: "ラーメン二郎"
    click_button "検索"

    expect(page).to have_content("市川海老蔵似のイケメン店主。豚ポタスープが特徴。")
  end

  it "酒名の検索ができる" do
    sign_in user

    create_post_with_relations(user: user)

    visit posts_path
    fill_in "q_shop_name_or_shop_sakes_name_or_shop_foods_name_or_shop_shop_places_address_cont", with: "キリンビール"
    click_button "検索"

    expect(page).to have_content("ラーメン二郎ひばりヶ丘店")
  end

  it "料理名の検索ができる" do
    sign_in user

    create_post_with_relations(user: user)

    visit posts_path
    fill_in "q_shop_name_or_shop_sakes_name_or_shop_foods_name_or_shop_shop_places_address_cont", with: "ラーメン"
    click_button "検索"

    expect(page).to have_content("キリンビール")
  end
end
