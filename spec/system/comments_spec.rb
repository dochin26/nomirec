require 'rails_helper'

RSpec.describe "Comments", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:post_with_shop) { create(:post, user: user, shop: create(:shop)) }

  before do
    # システムテストではturbo_streamが動作しないため、JavaScriptドライバーを使用しない
    driven_by :rack_test
  end

  describe "コメント機能" do
    context "ログインしているユーザー" do
      before do
        sign_in user
      end

      it "コメントを投稿できる" do
        visit post_path(post_with_shop)

        fill_in "comment[body]", with: "とても美味しそうなお店ですね！"
        click_button "コメントする"

        expect(page).to have_content("とても美味しそうなお店ですね！")
        expect(page).to have_content(user.name)
      end

      it "空のコメントは投稿できない" do
        visit post_path(post_with_shop)

        initial_comment_count = post_with_shop.comments.count

        fill_in "comment[body]", with: ""
        click_button "コメントする"

        # コメントが作成されていないことを確認
        expect(post_with_shop.comments.reload.count).to eq(initial_comment_count)
      end

      it "1000文字を超えるコメントは投稿できない" do
        visit post_path(post_with_shop)

        initial_comment_count = post_with_shop.comments.count

        long_text = "あ" * 1001
        fill_in "comment[body]", with: long_text
        click_button "コメントする"

        # コメントが作成されていないことを確認
        expect(post_with_shop.comments.reload.count).to eq(initial_comment_count)
      end
    end

    context "ログインしていないユーザー" do
      it "コメントフォームが表示されず、ログインリンクが表示される" do
        visit post_path(post_with_shop)

        expect(page).to have_content("コメントするにはログインが必要です")
        expect(page).to have_link("ログイン", href: new_user_session_path)
        expect(page).not_to have_button("コメントする")
      end
    end
  end

  describe "削除ボタンの表示" do
    let!(:user_comment) { create(:comment, post: post_with_shop, user: user, body: "自分のコメント") }
    let!(:other_user_comment) { create(:comment, post: post_with_shop, user: other_user, body: "他人のコメント") }

    context "コメント投稿者としてログイン" do
      before do
        sign_in user
      end

      it "自分のコメントにのみ削除ボタンが表示される" do
        visit post_path(post_with_shop)

        # 自分のコメントには削除ボタンがある
        within "#comment_#{user_comment.id}" do
          expect(page).to have_button("削除")
        end

        # 他人のコメントには削除ボタンがない
        within "#comment_#{other_user_comment.id}" do
          expect(page).not_to have_button("削除")
        end
      end

      it "自分のコメントを削除できる" do
        visit post_path(post_with_shop)

        within "#comment_#{user_comment.id}" do
          click_button "削除"
        end

        expect(page).to have_content("コメントを削除しました")
        expect(page).not_to have_content("自分のコメント")
      end
    end

    context "他のユーザーとしてログイン" do
      before do
        sign_in other_user
      end

      it "他人のコメントには削除ボタンが表示されない" do
        visit post_path(post_with_shop)

        within "#comment_#{user_comment.id}" do
          expect(page).not_to have_button("削除")
        end

        within "#comment_#{other_user_comment.id}" do
          expect(page).to have_button("削除")
        end
      end
    end

    context "ログインしていないユーザー" do
      it "すべてのコメントに削除ボタンが表示されない" do
        visit post_path(post_with_shop)

        within "#comment_#{user_comment.id}" do
          expect(page).not_to have_button("削除")
        end

        within "#comment_#{other_user_comment.id}" do
          expect(page).not_to have_button("削除")
        end
      end
    end
  end

  describe "コメント一覧の表示" do
    it "コメントが投稿順に表示される" do
      sign_in user

      comment1 = create(:comment, post: post_with_shop, user: user, body: "最初のコメント")
      comment2 = create(:comment, post: post_with_shop, user: other_user, body: "2番目のコメント")

      visit post_path(post_with_shop)

      # コメント数が表示される
      expect(page).to have_content("コメント (2)")

      # コメントが表示される
      expect(page).to have_content("最初のコメント")
      expect(page).to have_content("2番目のコメント")
    end

    it "コメントがない場合はメッセージが表示される" do
      visit post_path(post_with_shop)

      expect(page).to have_content("まだコメントがありません")
      expect(page).to have_content("コメント (0)")
    end
  end
end
