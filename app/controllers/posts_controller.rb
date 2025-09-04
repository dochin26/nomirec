class PostsController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action :check_owner, only: [ :edit, :update, :destroy ]

  def index
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true).includes(:shop, shop: [ :sakes, :foods ])
  end

  def new
    @post = Post.new
    @post.build_shop
    @post.shop.sakes.build
    @post.shop.foods.build
  end

  def show
  end

  def edit
    @post.shop.sakes.build if @post.shop.sakes.empty?
    @post.shop.foods.build if @post.shop.foods.empty?
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = "Post created successfully."
      redirect_to posts_path
    else
      flash.now[:danger] = "Failed to create post."
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      flash[:success] = "Post updated successfully."
      redirect_to posts_path
    else
      flash.now[:danger] = "Failed to update post."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy!
    redirect_to posts_path, notice: "投稿を削除しました。"
  rescue => e
    redirect_to posts_path, alert: "削除に失敗しました: #{e.message}"
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def check_owner
    redirect_to posts_path, alert: "Access denied." unless @post.user == current_user
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
        foods_attributes: [ :id, :name, :_destroy ]
      ]
    )
  end
end
