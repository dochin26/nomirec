class PostsController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action :check_owner, only: [ :edit, :update, :destroy ]

  def index
    @api_key = Rails.application.credentials.dig(:googlemaps, :api_key)
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true).includes(:shop, shop: [ :sakes, :foods, :shop_places ])

    gon.addresses = @addresses
    end

  def new
    @post = Post.new
    @post.build_shop
    @post.shop.sakes.build
    @post.shop.foods.build
    @post.shop.shop_places.build
  end

  def show
    @address = @post.shop.shop_places.pluck(:address).to_s
    gon.addresses = @address
  end

  def edit
    @post.shop.sakes.build if @post.shop.sakes.empty?
    @post.shop.foods.build if @post.shop.foods.empty?
    @post.shop.shop_places.build if @post.shop.shop_places.empty?
    @address = @post.shop.shop_places.pluck(:address).to_s
    gon.addresses = @address
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = t('posts.created')
      redirect_to posts_path
    else
      flash.now[:danger] = t('posts.create_failed')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      flash[:success] = t('posts.updated')
      redirect_to posts_path
    else
      flash.now[:danger] = t('posts.update_failed')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy!
    redirect_to posts_path, notice: t('posts.destroyed')
  rescue => e
    redirect_to posts_path, alert: t('posts.destroy_failed', error: e.message)
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def check_owner
    redirect_to posts_path, alert: t('posts.access_denied') unless @post.user == current_user
  end

  def post_params
    params.require(:post).permit(
      :comment,
      :shop_id,
      :body_image,
      shop_attributes: [
        :id,
        :name,
        :introduction,
        sakes_attributes: [ :id, :name, :_destroy ],
        foods_attributes: [ :id, :name, :_destroy ],
        shop_places_attributes: [ :id, :address, :_destroy ]
      ]
    )
  end
end
