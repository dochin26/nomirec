require 'rails_helper'

RSpec.describe 'Likeモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { like.valid? }

    let!(:other_like) { create(:like) }
    let(:like) { build(:like) }

    context '1User 1Shop 1いいね' do
      it '同じユーザーが同じ店舗に2回いいね出来ないこと' do
        like.user = other_like.user
        like.shop = other_like.shop
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'Userモデルとの関係' do
      it 'N:1となっている' do
        expect(Like.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context 'Shopモデルとの関係' do
      it 'N:1となっている' do
        expect(Like.reflect_on_association(:shop).macro).to eq :belongs_to
      end
    end
  end
end
