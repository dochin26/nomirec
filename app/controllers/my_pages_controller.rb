class MyPagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @posts = @user.posts.includes(:shop, body_image_attachment: :blob).order(created_at: :desc).page(params[:posts_page])
    @likes = @user.likes.includes(shop: [ :shop_places, :sakes, :foods ]).order(created_at: :desc).page(params[:likes_page])
  end
end
