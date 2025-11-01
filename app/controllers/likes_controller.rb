class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shop

  def create
    like = current_user.likes.build(shop_id: @shop.id)

    if like.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to request.referer, notice: "いいねしました" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("like_button_#{@shop.id}", partial: "likes/like_button", locals: { shop: @shop }) }
        format.html { redirect_to request.referer, alert: "いいねに失敗しました" }
      end
    end
  end

  def destroy
    like = current_user.likes.find_by(shop_id: @shop.id)

    if like&.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to request.referer, notice: "いいねを解除しました" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("like_button_#{@shop.id}", partial: "likes/like_button", locals: { shop: @shop }) }
        format.html { redirect_to request.referer, alert: "いいねの解除に失敗しました" }
      end
    end
  end

  private

  def set_shop
    @shop = Shop.find(params[:shop_id])
  end
end
