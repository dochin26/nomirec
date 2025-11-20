require 'rails_helper'

RSpec.describe "PostTags", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
    driven_by :rack_test
  end

  # 緯度経度を設定するヘルパーメソッド
  def set_location
    find("#modal-latitude-input", visible: false).set("35.6812362")
    find("#modal-longitude-input", visible: false).set("139.7671248")
  end

  describe "タグの投稿機能" do
    context "新規投稿ページから投稿する場合" do
      it "単一の酒名と料理名で投稿できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭"
        fill_in "料理名（複数の場合はスペース区切り）", with: "刺身"
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 投稿が正しく保存されていることを確認
        post = Post.last
        expect(post.shop.sakes.count).to eq(1)
        expect(post.shop.sakes.first.name).to eq("獺祭")
        expect(post.shop.foods.count).to eq(1)
        expect(post.shop.foods.first.name).to eq("刺身")
      end

      it "複数の酒名を半角スペース区切りで登録できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭 八海山 久保田"
        fill_in "料理名（複数の場合はスペース区切り）", with: "刺身"
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 3つの酒が登録されていることを確認
        post = Post.last
        expect(post.shop.sakes.count).to eq(3)
        expect(post.shop.sakes.pluck(:name)).to contain_exactly("獺祭", "八海山", "久保田")
      end

      it "複数の料理名を半角スペース区切りで登録できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭"
        fill_in "料理名（複数の場合はスペース区切り）", with: "刺身 焼き鳥 天ぷら"
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 3つの料理が登録されていることを確認
        post = Post.last
        expect(post.shop.foods.count).to eq(3)
        expect(post.shop.foods.pluck(:name)).to contain_exactly("刺身", "焼き鳥", "天ぷら")
      end

      it "複数の酒名を全角スペース区切りで登録できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭　八海山　久保田"
        fill_in "料理名（複数の場合はスペース区切り）", with: "刺身"
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 3つの酒が登録されていることを確認
        post = Post.last
        expect(post.shop.sakes.count).to eq(3)
        expect(post.shop.sakes.pluck(:name)).to contain_exactly("獺祭", "八海山", "久保田")
      end

      it "複数の料理名を全角スペース区切りで登録できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭"
        fill_in "料理名（複数の場合はスペース区切り）", with: "刺身　焼き鳥　天ぷら"
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 3つの料理が登録されていることを確認
        post = Post.last
        expect(post.shop.foods.count).to eq(3)
        expect(post.shop.foods.pluck(:name)).to contain_exactly("刺身", "焼き鳥", "天ぷら")
      end

      it "半角と全角スペースが混在していても正しく登録できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭 八海山　久保田"
        fill_in "料理名（複数の場合はスペース区切り）", with: "刺身　焼き鳥 天ぷら"
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 正しく登録されていることを確認
        post = Post.last
        expect(post.shop.sakes.count).to eq(3)
        expect(post.shop.sakes.pluck(:name)).to contain_exactly("獺祭", "八海山", "久保田")
        expect(post.shop.foods.count).to eq(3)
        expect(post.shop.foods.pluck(:name)).to contain_exactly("刺身", "焼き鳥", "天ぷら")
      end

      it "連続したスペースがあっても正しく登録できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭  八海山   久保田"
        fill_in "料理名（複数の場合はスペース区切り）", with: "刺身"
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 連続スペースを無視して3つの酒が登録されていることを確認
        post = Post.last
        expect(post.shop.sakes.count).to eq(3)
        expect(post.shop.sakes.pluck(:name)).to contain_exactly("獺祭", "八海山", "久保田")
      end

      it "前後にスペースがあっても正しく登録できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "  獺祭 八海山 久保田  "
        fill_in "料理名（複数の場合はスペース区切り）", with: "  刺身 焼き鳥  "
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 前後のスペースを無視して正しく登録されていることを確認
        post = Post.last
        expect(post.shop.sakes.count).to eq(3)
        expect(post.shop.sakes.pluck(:name)).to contain_exactly("獺祭", "八海山", "久保田")
        expect(post.shop.foods.count).to eq(2)
        expect(post.shop.foods.pluck(:name)).to contain_exactly("刺身", "焼き鳥")
      end

      it "5つ以上の酒名を登録できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭 八海山 久保田 越乃寒梅 真澄"
        fill_in "料理名（複数の場合はスペース区切り）", with: "刺身"
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 5つの酒が登録されていることを確認
        post = Post.last
        expect(post.shop.sakes.count).to eq(5)
        expect(post.shop.sakes.pluck(:name)).to contain_exactly("獺祭", "八海山", "久保田", "越乃寒梅", "真澄")
      end

      it "5つ以上の料理名を登録できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭"
        fill_in "料理名（複数の場合はスペース区切り）", with: "刺身 焼き鳥 天ぷら 唐揚げ ポテトフライ"
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 5つの料理が登録されていることを確認
        post = Post.last
        expect(post.shop.foods.count).to eq(5)
        expect(post.shop.foods.pluck(:name)).to contain_exactly("刺身", "焼き鳥", "天ぷら", "唐揚げ", "ポテトフライ")
      end
    end

    context "空の入力の場合" do
      it "酒名が空でも投稿できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: ""
        fill_in "料理名（複数の場合はスペース区切り）", with: "刺身"
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 酒が登録されていないことを確認
        post = Post.last
        expect(post.shop.sakes.count).to eq(0)
        expect(post.shop.foods.count).to eq(1)
      end

      it "料理名が空でも投稿できる" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭"
        fill_in "料理名（複数の場合はスペース区切り）", with: ""
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 料理が登録されていないことを確認
        post = Post.last
        expect(post.shop.sakes.count).to eq(1)
        expect(post.shop.foods.count).to eq(0)
      end

      it "スペースのみの入力では何も登録されない" do
        visit new_post_path
        set_location

        fill_in "店名", with: "居酒屋テスト"
        fill_in "説明", with: "テスト説明"
        fill_in "酒名（複数の場合はスペース区切り）", with: "   "
        fill_in "料理名（複数の場合はスペース区切り）", with: "   "
        click_button "投稿する"

        expect(page).to have_content("投稿を作成しました")

        # 何も登録されていないことを確認
        post = Post.last
        expect(post.shop.sakes.count).to eq(0)
        expect(post.shop.foods.count).to eq(0)
      end
    end
  end

  describe "既存のタグの再利用" do
    it "同じ酒名で投稿した場合、既存の酒レコードが再利用される" do
      visit new_post_path
        set_location

      fill_in "店名", with: "居酒屋テスト1"
      fill_in "説明", with: "テスト説明1"
      fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭"
      fill_in "料理名（複数の場合はスペース区切り）", with: "刺身"
      click_button "投稿する"

      expect(page).to have_content("投稿を作成しました")

      # 獺祭が1つ作成される
      expect(Sake.where(name: "獺祭").count).to eq(1)

      # 2回目の投稿
      visit new_post_path
        set_location

      fill_in "店名", with: "居酒屋テスト2"
      fill_in "説明", with: "テスト説明2"
      fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭"
      fill_in "料理名（複数の場合はスペース区切り）", with: "焼き鳥"
      click_button "投稿する"

      expect(page).to have_content("投稿を作成しました")

      # 獺祭はまだ1つのまま（重複作成されない）
      expect(Sake.where(name: "獺祭").count).to eq(1)

      # 2つの投稿で同じ酒レコードを参照している
      sake = Sake.find_by(name: "獺祭")
      expect(sake.shops.count).to eq(2)
    end

    it "同じ料理名で投稿した場合、既存の料理レコードが再利用される" do
      visit new_post_path
        set_location

      fill_in "店名", with: "居酒屋テスト1"
      fill_in "説明", with: "テスト説明1"
      fill_in "酒名（複数の場合はスペース区切り）", with: "獺祭"
      fill_in "料理名（複数の場合はスペース区切り）", with: "刺身"
      click_button "投稿する"

      expect(page).to have_content("投稿を作成しました")

      # 刺身が1つ作成される
      expect(Food.where(name: "刺身").count).to eq(1)

      # 2回目の投稿
      visit new_post_path
        set_location

      fill_in "店名", with: "居酒屋テスト2"
      fill_in "説明", with: "テスト説明2"
      fill_in "酒名（複数の場合はスペース区切り）", with: "八海山"
      fill_in "料理名（複数の場合はスペース区切り）", with: "刺身"
      click_button "投稿する"

      expect(page).to have_content("投稿を作成しました")

      # 刺身はまだ1つのまま（重複作成されない）
      expect(Food.where(name: "刺身").count).to eq(1)

      # 2つの投稿で同じ料理レコードを参照している
      food = Food.find_by(name: "刺身")
      expect(food.shops.count).to eq(2)
    end
  end

  describe "タグ登録数の確認" do
    it "スペース区切りで指定した数だけ酒が登録される" do
      visit new_post_path
        set_location

      fill_in "店名", with: "居酒屋テスト"
      fill_in "説明", with: "テスト説明"
      fill_in "酒名（複数の場合はスペース区切り）", with: "酒1 酒2 酒3"
      fill_in "料理名（複数の場合はスペース区切り）", with: "料理1"
      click_button "投稿する"

      expect(page).to have_content("投稿を作成しました")

      post = Post.last
      # 3つの酒が登録される
      expect(post.shop.sakes.count).to eq(3)
      expect(Sake.count).to eq(3)
    end

    it "スペース区切りで指定した数だけ料理が登録される" do
      visit new_post_path
        set_location

      fill_in "店名", with: "居酒屋テスト"
      fill_in "説明", with: "テスト説明"
      fill_in "酒名（複数の場合はスペース区切り）", with: "酒1"
      fill_in "料理名（複数の場合はスペース区切り）", with: "料理1 料理2 料理3 料理4"
      click_button "投稿する"

      expect(page).to have_content("投稿を作成しました")

      post = Post.last
      # 4つの料理が登録される
      expect(post.shop.foods.count).to eq(4)
      expect(Food.count).to eq(4)
    end
  end
end
